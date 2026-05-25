-- ============================================================================
-- GARAGE ATELIER — Migration 03 : Row Level Security
-- ============================================================================
-- À exécuter APRÈS 02_functions_triggers.sql
-- ============================================================================
-- Modèle de sécurité :
-- - admin     : accès complet en lecture/écriture sur toutes les tables
-- - mechanic  : lecture du planning global, lecture/écriture sur SES interventions
-- - client    : lecture de SES données uniquement
-- - public    : aucun accès direct DB ; les opérations publiques (création de
--               demande RDV) passent par des Server Actions Next.js avec
--               service_role côté serveur, jamais via le client navigateur.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Activer RLS sur toutes les tables
-- ----------------------------------------------------------------------------
alter table public.profiles                        enable row level security;
alter table public.garage_settings                 enable row level security;
alter table public.specialties                     enable row level security;
alter table public.mechanics                       enable row level security;
alter table public.mechanic_specialties            enable row level security;
alter table public.mechanic_schedules              enable row level security;
alter table public.time_off                        enable row level security;
alter table public.clients                         enable row level security;
alter table public.vehicles                        enable row level security;
alter table public.intervention_types              enable row level security;
alter table public.intervention_type_specialties   enable row level security;
alter table public.interventions                   enable row level security;
alter table public.intervention_status_log         enable row level security;
alter table public.documents                       enable row level security;
alter table public.reviews                         enable row level security;
alter table public.notifications                   enable row level security;
alter table public.maintenance_reminders           enable row level security;
alter table public.google_tokens                   enable row level security;
alter table public.magic_link_tokens               enable row level security;

-- ----------------------------------------------------------------------------
-- Helper : drop systématique des policies existantes avant recréation
-- ----------------------------------------------------------------------------
do $$
declare
  r record;
begin
  for r in
    select schemaname, tablename, policyname
    from pg_policies
    where schemaname = 'public'
  loop
    execute format('drop policy if exists %I on %I.%I', r.policyname, r.schemaname, r.tablename);
  end loop;
end$$;

-- ============================================================================
-- profiles
-- ============================================================================
-- Chaque user peut lire/modifier son propre profil
-- Admin peut tout faire
create policy "profiles: self can read"
  on public.profiles for select
  using (id = auth.uid() or public.is_admin());

create policy "profiles: self can update"
  on public.profiles for update
  using (id = auth.uid())
  with check (id = auth.uid() and app_role = (select app_role from public.profiles where id = auth.uid()));
  -- Note : un user ne peut PAS changer son propre app_role (sécurité critique)

create policy "profiles: admin can manage"
  on public.profiles for all
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================================
-- garage_settings — Lecture libre pour staff + clients connectés, écriture admin only
-- ============================================================================
create policy "garage_settings: all authenticated can read"
  on public.garage_settings for select
  using (auth.uid() is not null);

create policy "garage_settings: admin can manage"
  on public.garage_settings for all
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================================
-- specialties — Lecture staff, écriture admin
-- ============================================================================
create policy "specialties: staff can read"
  on public.specialties for select
  using (public.is_staff());

create policy "specialties: admin can manage"
  on public.specialties for all
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================================
-- mechanics — Staff lit, admin écrit, mécanicien voit son enregistrement
-- ============================================================================
create policy "mechanics: staff can read"
  on public.mechanics for select
  using (public.is_staff());

create policy "mechanics: admin can manage"
  on public.mechanics for all
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================================
-- mechanic_specialties
-- ============================================================================
create policy "mechanic_specialties: staff can read"
  on public.mechanic_specialties for select
  using (public.is_staff());

create policy "mechanic_specialties: admin can manage"
  on public.mechanic_specialties for all
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================================
-- mechanic_schedules
-- ============================================================================
create policy "mechanic_schedules: staff can read"
  on public.mechanic_schedules for select
  using (public.is_staff());

create policy "mechanic_schedules: admin can manage"
  on public.mechanic_schedules for all
  using (public.is_admin())
  with check (public.is_admin());

-- Le mécanicien peut modifier ses propres horaires (par ex. au cas où l'admin l'autorise)
create policy "mechanic_schedules: mechanic can read own"
  on public.mechanic_schedules for select
  using (mechanic_id = public.current_mechanic_id());

-- ============================================================================
-- time_off
-- ============================================================================
create policy "time_off: staff can read"
  on public.time_off for select
  using (public.is_staff());

create policy "time_off: mechanic can request own"
  on public.time_off for insert
  with check (
    public.is_mechanic()
    and mechanic_id = public.current_mechanic_id()
    and approved = false
  );

create policy "time_off: mechanic can update own pending"
  on public.time_off for update
  using (
    public.is_mechanic()
    and mechanic_id = public.current_mechanic_id()
    and approved = false
  );

create policy "time_off: admin can manage"
  on public.time_off for all
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================================
-- clients
-- ============================================================================
create policy "clients: staff can read all"
  on public.clients for select
  using (public.is_staff());

create policy "clients: client can read own"
  on public.clients for select
  using (id = public.current_client_id());

create policy "clients: admin can manage"
  on public.clients for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "clients: client can update own contact"
  on public.clients for update
  using (id = public.current_client_id())
  with check (
    id = public.current_client_id()
    -- Empêche le client de changer ce qui ne le concerne pas
    and is_anonymized = (select is_anonymized from public.clients where id = public.current_client_id())
  );

-- ============================================================================
-- vehicles
-- ============================================================================
create policy "vehicles: staff can read all"
  on public.vehicles for select
  using (public.is_staff());

create policy "vehicles: client can read own"
  on public.vehicles for select
  using (client_id = public.current_client_id());

create policy "vehicles: admin can manage"
  on public.vehicles for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "vehicles: client can manage own"
  on public.vehicles for all
  using (client_id = public.current_client_id())
  with check (client_id = public.current_client_id());

-- ============================================================================
-- intervention_types — Lecture par tout user authentifié (besoin pour booking)
-- ============================================================================
create policy "intervention_types: authenticated can read"
  on public.intervention_types for select
  using (auth.uid() is not null and is_active = true);

create policy "intervention_types: staff can read all"
  on public.intervention_types for select
  using (public.is_staff());

create policy "intervention_types: admin can manage"
  on public.intervention_types for all
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================================
-- intervention_type_specialties
-- ============================================================================
create policy "intervention_type_specialties: authenticated can read"
  on public.intervention_type_specialties for select
  using (auth.uid() is not null);

create policy "intervention_type_specialties: admin can manage"
  on public.intervention_type_specialties for all
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================================
-- interventions — Cœur de la sécurité
-- ============================================================================

-- Lecture admin : tout
create policy "interventions: admin can read all"
  on public.interventions for select
  using (public.is_admin());

-- Lecture mécanicien : ses interventions assignées
create policy "interventions: mechanic reads own"
  on public.interventions for select
  using (
    public.is_mechanic()
    and mechanic_id = public.current_mechanic_id()
  );

-- Lecture client : ses interventions
create policy "interventions: client reads own"
  on public.interventions for select
  using (client_id = public.current_client_id());

-- Création/modification admin : libre
create policy "interventions: admin can manage"
  on public.interventions for all
  using (public.is_admin())
  with check (public.is_admin());

-- Modification mécanicien : uniquement statut + horaires réels + notes internes sur SES interventions
-- Note : la granularité fine (quelles colonnes) est gérée côté Server Action,
-- pas en RLS (PostgreSQL ne fait pas de column-level RLS facilement).
create policy "interventions: mechanic updates own"
  on public.interventions for update
  using (
    public.is_mechanic()
    and mechanic_id = public.current_mechanic_id()
    and status in ('scheduled', 'in_progress', 'on_hold')
  )
  with check (
    public.is_mechanic()
    and mechanic_id = public.current_mechanic_id()
  );

-- ============================================================================
-- intervention_status_log — Lecture staff, écriture trigger only
-- ============================================================================
create policy "status_log: staff can read"
  on public.intervention_status_log for select
  using (public.is_staff());

create policy "status_log: client reads own"
  on public.intervention_status_log for select
  using (
    intervention_id in (
      select id from public.interventions where client_id = public.current_client_id()
    )
  );

-- Note : l'insertion est faite par trigger (security definer), pas besoin de policy INSERT explicite

-- ============================================================================
-- documents
-- ============================================================================
create policy "documents: staff can read"
  on public.documents for select
  using (public.is_staff());

create policy "documents: client reads own visible"
  on public.documents for select
  using (
    is_client_visible = true
    and intervention_id in (
      select id from public.interventions where client_id = public.current_client_id()
    )
  );

create policy "documents: admin can manage"
  on public.documents for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "documents: mechanic can add to own intervention"
  on public.documents for insert
  with check (
    public.is_mechanic()
    and intervention_id in (
      select id from public.interventions where mechanic_id = public.current_mechanic_id()
    )
  );

-- ============================================================================
-- reviews
-- ============================================================================
create policy "reviews: published are public"
  on public.reviews for select
  using (is_published = true or public.is_staff() or client_id = public.current_client_id());

create policy "reviews: client creates own"
  on public.reviews for insert
  with check (
    client_id = public.current_client_id()
    and intervention_id in (
      select id from public.interventions
      where client_id = public.current_client_id()
        and status in ('completed', 'delivered')
    )
  );

create policy "reviews: client updates own"
  on public.reviews for update
  using (client_id = public.current_client_id())
  with check (client_id = public.current_client_id());

create policy "reviews: admin can manage"
  on public.reviews for all
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================================
-- notifications — Lecture staff + client concerné, écriture service_role only
-- ============================================================================
create policy "notifications: staff can read"
  on public.notifications for select
  using (public.is_staff());

create policy "notifications: client reads own"
  on public.notifications for select
  using (client_id = public.current_client_id());

-- L'insertion se fait via Edge Functions avec service_role, qui bypasse RLS.
-- Aucune policy INSERT publique nécessaire.

-- ============================================================================
-- maintenance_reminders
-- ============================================================================
create policy "reminders: staff can read"
  on public.maintenance_reminders for select
  using (public.is_staff());

create policy "reminders: client reads own"
  on public.maintenance_reminders for select
  using (
    vehicle_id in (
      select id from public.vehicles where client_id = public.current_client_id()
    )
  );

create policy "reminders: admin can manage"
  on public.maintenance_reminders for all
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================================
-- google_tokens — Sensible : lecture mécanicien (le sien) + service_role only
-- ============================================================================
create policy "google_tokens: mechanic reads own"
  on public.google_tokens for select
  using (mechanic_id = public.current_mechanic_id());

create policy "google_tokens: mechanic can manage own"
  on public.google_tokens for all
  using (mechanic_id = public.current_mechanic_id())
  with check (mechanic_id = public.current_mechanic_id());

-- ============================================================================
-- magic_link_tokens — Aucun accès direct, géré uniquement via service_role
-- ============================================================================
-- RLS active mais aucune policy => tout accès via la clé anonyme est refusé.
-- Seul le service_role peut lire/créer ces tokens (côté Server Action).

-- ============================================================================
-- FIN — Migration 03 : RLS Policies
-- ============================================================================
-- Prochaine étape : exécuter 04_seed.sql
-- ============================================================================
