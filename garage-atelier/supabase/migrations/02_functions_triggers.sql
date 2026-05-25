-- ============================================================================
-- GARAGE ATELIER — Migration 02 : Fonctions et triggers
-- ============================================================================
-- À exécuter APRÈS 01_schema.sql
-- Idempotent : les CREATE OR REPLACE et DROP IF EXISTS rendent ré-exécutable
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Helper : récupérer le rôle applicatif de l'utilisateur courant
-- ----------------------------------------------------------------------------
-- Utilisé massivement dans les RLS policies. STABLE pour permettre le cache
-- du planner sur la durée d'une requête.
create or replace function public.app_role()
returns public.app_role
language sql
stable
security definer
set search_path = public, auth
as $$
  select coalesce(
    (auth.jwt() -> 'app_metadata' ->> 'app_role')::public.app_role,
    case
      when auth.uid() is null then null
      else (select app_role from public.profiles where id = auth.uid())
    end
  );
$$;

comment on function public.app_role() is
  'Renvoie le rôle applicatif (admin/mechanic/client) du user courant. Utilisé dans les RLS.';

-- ----------------------------------------------------------------------------
-- 2. Helper : vérifier si l'utilisateur est admin
-- ----------------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
stable
as $$
  select public.app_role() = 'admin';
$$;

-- ----------------------------------------------------------------------------
-- 3. Helper : vérifier si l'utilisateur est mécanicien
-- ----------------------------------------------------------------------------
create or replace function public.is_mechanic()
returns boolean
language sql
stable
as $$
  select public.app_role() = 'mechanic';
$$;

-- ----------------------------------------------------------------------------
-- 4. Helper : vérifier si l'utilisateur est staff (admin OU mécanicien)
-- ----------------------------------------------------------------------------
create or replace function public.is_staff()
returns boolean
language sql
stable
as $$
  select public.app_role() in ('admin', 'mechanic');
$$;

-- ----------------------------------------------------------------------------
-- 5. Helper : récupérer le mechanic_id correspondant au user courant
-- ----------------------------------------------------------------------------
create or replace function public.current_mechanic_id()
returns uuid
language sql
stable
as $$
  select id from public.mechanics where profile_id = auth.uid() limit 1;
$$;

-- ----------------------------------------------------------------------------
-- 6. Helper : récupérer le client_id correspondant au user courant
-- ----------------------------------------------------------------------------
create or replace function public.current_client_id()
returns uuid
language sql
stable
as $$
  select id from public.clients where profile_id = auth.uid() limit 1;
$$;

-- ----------------------------------------------------------------------------
-- 7. Trigger générique : auto-update du champ updated_at
-- ----------------------------------------------------------------------------
create or replace function public.tg_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Appliquer à toutes les tables possédant updated_at
do $$
declare
  t text;
  tables_with_updated_at text[] := array[
    'profiles', 'garage_settings', 'specialties', 'mechanics',
    'time_off', 'clients', 'vehicles', 'intervention_types',
    'interventions', 'maintenance_reminders', 'google_tokens'
  ];
begin
  foreach t in array tables_with_updated_at loop
    execute format('drop trigger if exists set_updated_at on public.%I', t);
    execute format(
      'create trigger set_updated_at before update on public.%I '
      'for each row execute function public.tg_set_updated_at()',
      t
    );
  end loop;
end$$;

-- ----------------------------------------------------------------------------
-- 8. Trigger : log automatique des changements de statut d'intervention
-- ----------------------------------------------------------------------------
create or replace function public.tg_log_intervention_status_change()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    insert into public.intervention_status_log (intervention_id, from_status, to_status, changed_by)
    values (new.id, null, new.status, auth.uid());
  elsif tg_op = 'UPDATE' and old.status is distinct from new.status then
    insert into public.intervention_status_log (intervention_id, from_status, to_status, changed_by)
    values (new.id, old.status, new.status, auth.uid());
  end if;
  return new;
end;
$$;

drop trigger if exists log_status_change on public.interventions;
create trigger log_status_change
  after insert or update of status on public.interventions
  for each row execute function public.tg_log_intervention_status_change();

-- ----------------------------------------------------------------------------
-- 9. Trigger : auto-définir scheduled_end si seul scheduled_start est fourni
-- ----------------------------------------------------------------------------
-- Calcule scheduled_end à partir de scheduled_start + default_duration_min du type
create or replace function public.tg_compute_scheduled_end()
returns trigger
language plpgsql
as $$
declare
  duration_min smallint;
begin
  if new.scheduled_start is not null and new.scheduled_end is null then
    select default_duration_min into duration_min
    from public.intervention_types where id = new.intervention_type_id;

    if duration_min is not null then
      new.scheduled_end := new.scheduled_start + (duration_min || ' minutes')::interval;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists compute_scheduled_end on public.interventions;
create trigger compute_scheduled_end
  before insert or update of scheduled_start, intervention_type_id on public.interventions
  for each row execute function public.tg_compute_scheduled_end();

-- ----------------------------------------------------------------------------
-- 10. Trigger : créer auto une ligne profiles à la création d'un auth user
-- ----------------------------------------------------------------------------
create or replace function public.tg_handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  insert into public.profiles (id, email, full_name, app_role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.email),
    coalesce(
      (new.raw_app_meta_data ->> 'app_role')::public.app_role,
      'client'
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.tg_handle_new_user();

-- ----------------------------------------------------------------------------
-- 11. Fonction métier : créneaux disponibles pour un type d'intervention
-- ----------------------------------------------------------------------------
-- Renvoie les créneaux libres entre deux dates, en tenant compte de :
-- - Horaires d'ouverture du garage (garage_settings.opening_hours)
-- - Jours fériés
-- - Horaires des mécaniciens (mechanic_schedules)
-- - Congés (time_off)
-- - RDV déjà planifiés
-- - Marge de sécurité paramétrée
--
-- Pour le MVP : renvoie les créneaux par mécanicien capable, sans filtrage spécialité
-- (la logique de matching spécialités est laissée à l'application qui pré-filtre).
create or replace function public.available_slots(
  p_intervention_type_id uuid,
  p_from timestamptz,
  p_to   timestamptz,
  p_mechanic_id uuid default null  -- null = tous les mécanos
)
returns table (
  slot_start timestamptz,
  slot_end timestamptz,
  mechanic_id uuid,
  mechanic_name text
)
language plpgsql
stable
as $$
declare
  v_duration_min smallint;
  v_granularity smallint;
  v_margin_min smallint;
  v_timezone text;
  v_opening_hours jsonb;
  v_public_holidays date[];
begin
  -- Récupération de la durée et des paramètres garage
  select default_duration_min into v_duration_min
  from public.intervention_types where id = p_intervention_type_id;

  if v_duration_min is null then
    raise exception 'Intervention type not found: %', p_intervention_type_id;
  end if;

  select slot_granularity_min, safety_margin_min, timezone, opening_hours, public_holidays
    into v_granularity, v_margin_min, v_timezone, v_opening_hours, v_public_holidays
  from public.garage_settings where id = 1;

  return query
  with
  -- Génération de tous les créneaux candidats à la granularité du garage
  raw_slots as (
    select gs as slot_start,
           gs + (v_duration_min || ' minutes')::interval as slot_end
    from generate_series(p_from, p_to - (v_duration_min || ' minutes')::interval, (v_granularity || ' minutes')::interval) gs
  ),
  -- Mécaniciens actifs (filtrés si p_mechanic_id fourni)
  active_mechanics as (
    select m.id, m.first_name || ' ' || m.last_name as full_name
    from public.mechanics m
    where m.is_active = true
      and (p_mechanic_id is null or m.id = p_mechanic_id)
  ),
  -- Croisement créneaux × mécanos
  candidates as (
    select rs.slot_start, rs.slot_end, am.id as mechanic_id, am.full_name
    from raw_slots rs
    cross join active_mechanics am
  ),
  -- Filtrage : pas dans un jour férié
  no_holidays as (
    select * from candidates c
    where (c.slot_start at time zone v_timezone)::date != all(v_public_holidays)
  ),
  -- Filtrage : dans les horaires du mécanicien ce jour-là
  in_mechanic_hours as (
    select c.*
    from no_holidays c
    join public.mechanic_schedules ms
      on ms.mechanic_id = c.mechanic_id
      and ms.day_of_week = extract(dow from c.slot_start at time zone v_timezone)::smallint
      and (c.slot_start at time zone v_timezone)::time >= ms.start_time
      and (c.slot_end at time zone v_timezone)::time <= ms.end_time
  ),
  -- Filtrage : pas en congé
  not_off as (
    select c.*
    from in_mechanic_hours c
    where not exists (
      select 1 from public.time_off t
      where t.mechanic_id = c.mechanic_id
        and t.approved = true
        and (c.slot_start at time zone v_timezone)::date between t.start_date and t.end_date
    )
  ),
  -- Filtrage : pas de conflit avec un RDV existant (avec marge de sécurité)
  no_conflict as (
    select c.*
    from not_off c
    where not exists (
      select 1 from public.interventions i
      where i.mechanic_id = c.mechanic_id
        and i.status in ('scheduled', 'in_progress', 'on_hold')
        and i.scheduled_start is not null
        and i.scheduled_end is not null
        and tstzrange(
              c.slot_start - (v_margin_min || ' minutes')::interval,
              c.slot_end   + (v_margin_min || ' minutes')::interval,
              '[)'
            )
            && tstzrange(i.scheduled_start, i.scheduled_end, '[)')
    )
  )
  select slot_start, slot_end, mechanic_id, full_name as mechanic_name
  from no_conflict
  order by slot_start, mechanic_id;
end;
$$;

comment on function public.available_slots is
  'Renvoie les créneaux libres pour un type d''intervention entre deux dates. Tient compte des horaires garage, congés, marges et conflits existants.';

-- ----------------------------------------------------------------------------
-- 12. Fonction métier : créer automatiquement les maintenance_reminders
-- ----------------------------------------------------------------------------
-- Appelée par trigger sur vehicles pour générer les rappels CT et vidange
create or replace function public.tg_create_vehicle_reminders()
returns trigger
language plpgsql
as $$
begin
  -- Rappel contrôle technique
  if new.next_technical_inspection is not null
     and (tg_op = 'INSERT' or old.next_technical_inspection is distinct from new.next_technical_inspection)
  then
    -- Supprimer l'ancien rappel non envoyé s'il existe
    delete from public.maintenance_reminders
    where vehicle_id = new.id and reminder_type = 'technical_inspection' and notified_at is null;

    -- Créer un nouveau rappel 30 jours avant
    insert into public.maintenance_reminders (
      vehicle_id, reminder_type, due_date, message, is_recurring, recurrence_months
    ) values (
      new.id,
      'technical_inspection',
      new.next_technical_inspection - interval '30 days',
      'Le contrôle technique de votre véhicule arrive à échéance.',
      true,
      24
    );
  end if;

  return new;
end;
$$;

drop trigger if exists create_vehicle_reminders on public.vehicles;
create trigger create_vehicle_reminders
  after insert or update of next_technical_inspection on public.vehicles
  for each row execute function public.tg_create_vehicle_reminders();

-- ----------------------------------------------------------------------------
-- 13. Fonction RGPD : anonymisation d'un client
-- ----------------------------------------------------------------------------
-- Anonymise un client tout en conservant l'historique métier
-- À appeler uniquement par admin
create or replace function public.anonymize_client(p_client_id uuid)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if not public.is_admin() then
    raise exception 'Seul un admin peut anonymiser un client';
  end if;

  update public.clients
  set first_name = 'Anonyme',
      last_name = '#' || substring(id::text, 1, 8),
      email = null,
      phone = null,
      address = null,
      city = null,
      postal_code = null,
      company_name = null,
      vat_number = null,
      notes = null,
      sms_opt_in = false,
      email_opt_in = false,
      marketing_opt_in = false,
      is_anonymized = true,
      anonymized_at = now()
  where id = p_client_id;

  -- Révoquer tous les magic links actifs
  update public.magic_link_tokens
  set revoked_at = now()
  where client_id = p_client_id and revoked_at is null and used_at is null;

  -- Si compte auth associé, le désactiver via metadata
  update auth.users
  set raw_app_meta_data = raw_app_meta_data || jsonb_build_object('disabled', true)
  where id = (select profile_id from public.clients where id = p_client_id);
end;
$$;

-- ----------------------------------------------------------------------------
-- 14. Fonction KPI : taux d'occupation atelier sur une période
-- ----------------------------------------------------------------------------
create or replace function public.kpi_workshop_occupancy(
  p_from date,
  p_to date
)
returns numeric
language plpgsql
stable
as $$
declare
  v_total_minutes_available numeric := 0;
  v_total_minutes_booked numeric := 0;
  v_capacity smallint;
  v_opening_hours jsonb;
  v_holidays date[];
  v_day date;
  v_day_of_week text;
  v_slots jsonb;
  v_slot jsonb;
begin
  select workshop_capacity, opening_hours, public_holidays
    into v_capacity, v_opening_hours, v_holidays
  from public.garage_settings where id = 1;

  -- Calcul minutes ouvrées
  v_day := p_from;
  while v_day <= p_to loop
    if v_day != all(v_holidays) then
      v_day_of_week := lower(to_char(v_day, 'FMday'));
      -- Conversion français vers anglais si besoin (à adapter selon locale)
      v_day_of_week := case extract(dow from v_day)
        when 0 then 'sunday' when 1 then 'monday' when 2 then 'tuesday'
        when 3 then 'wednesday' when 4 then 'thursday' when 5 then 'friday'
        when 6 then 'saturday'
      end;
      v_slots := v_opening_hours -> v_day_of_week;
      if v_slots is not null then
        for v_slot in select * from jsonb_array_elements(v_slots) loop
          v_total_minutes_available := v_total_minutes_available + (
            extract(epoch from (v_slot ->> 'end')::time - (v_slot ->> 'start')::time) / 60
          ) * v_capacity;
        end loop;
      end if;
    end if;
    v_day := v_day + 1;
  end loop;

  -- Calcul minutes effectivement bookées
  select coalesce(sum(extract(epoch from (scheduled_end - scheduled_start)) / 60), 0)
    into v_total_minutes_booked
  from public.interventions
  where status in ('scheduled', 'in_progress', 'completed', 'delivered')
    and scheduled_start::date between p_from and p_to;

  if v_total_minutes_available = 0 then
    return 0;
  end if;

  return round((v_total_minutes_booked / v_total_minutes_available * 100)::numeric, 2);
end;
$$;

-- ----------------------------------------------------------------------------
-- 15. Vue : interventions enrichies (jointures fréquentes)
-- ----------------------------------------------------------------------------
create or replace view public.v_interventions_full as
select
  i.id,
  i.status,
  i.scheduled_start,
  i.scheduled_end,
  i.actual_start,
  i.actual_end,
  i.client_notes,
  i.internal_notes,
  i.client_visible_notes,
  i.final_price_eur,
  i.vehicle_mileage_km,
  i.created_at,
  i.updated_at,
  -- Client
  c.id as client_id,
  c.first_name || ' ' || c.last_name as client_name,
  c.email as client_email,
  c.phone as client_phone,
  -- Véhicule
  v.id as vehicle_id,
  v.license_plate,
  v.brand || ' ' || v.model as vehicle_label,
  v.brand as vehicle_brand,
  v.model as vehicle_model,
  -- Type d'intervention
  it.id as intervention_type_id,
  it.name as intervention_type_name,
  it.color_hex as intervention_color,
  it.default_duration_min,
  -- Mécanicien
  m.id as mechanic_id,
  case when m.id is not null then m.first_name || ' ' || m.last_name end as mechanic_name,
  m.color_hex as mechanic_color
from public.interventions i
join public.clients c on c.id = i.client_id
join public.vehicles v on v.id = i.vehicle_id
join public.intervention_types it on it.id = i.intervention_type_id
left join public.mechanics m on m.id = i.mechanic_id;

comment on view public.v_interventions_full is
  'Vue dénormalisée des interventions avec toutes les infos client/véhicule/type/mécano. Utilisée par le planning et les KPI.';

-- ============================================================================
-- FIN — Migration 02 : Fonctions et triggers
-- ============================================================================
-- Prochaine étape : exécuter 03_rls_policies.sql
-- ============================================================================
