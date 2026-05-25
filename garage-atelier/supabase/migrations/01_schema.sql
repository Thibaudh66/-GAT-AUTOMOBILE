-- ============================================================================
-- GARAGE ATELIER — Migration 01 : Schéma complet
-- ============================================================================
-- À exécuter dans le SQL Editor de Supabase (Project → SQL Editor → New query)
-- Idempotent : peut être ré-exécuté sans erreur grâce aux IF NOT EXISTS / IF EXISTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. Extensions PostgreSQL nécessaires
-- ----------------------------------------------------------------------------
create extension if not exists "uuid-ossp";         -- uuid_generate_v4()
create extension if not exists "pgcrypto";          -- gen_random_uuid(), digest()
create extension if not exists "pg_trgm";           -- recherche textuelle (clients, véhicules)
create extension if not exists "btree_gist";        -- contraintes d'exclusion temporelles (anti-conflit)

-- ----------------------------------------------------------------------------
-- 1. ENUMs métier
-- ----------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_type where typname = 'app_role') then
    create type public.app_role as enum ('admin', 'mechanic', 'client');
  end if;

  if not exists (select 1 from pg_type where typname = 'intervention_status') then
    create type public.intervention_status as enum (
      'pending_approval',  -- Demande client en attente de validation admin
      'scheduled',         -- Validé et planifié
      'in_progress',       -- Mécanicien a démarré l'intervention
      'on_hold',           -- Mis en pause (attente pièce, etc.)
      'completed',         -- Terminé, prêt à récupérer
      'delivered',         -- Véhicule restitué au client
      'cancelled',         -- Annulé
      'no_show'            -- Client absent
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'notification_channel') then
    create type public.notification_channel as enum ('email', 'sms');
  end if;

  if not exists (select 1 from pg_type where typname = 'notification_status') then
    create type public.notification_status as enum ('queued', 'sent', 'failed', 'skipped');
  end if;

  if not exists (select 1 from pg_type where typname = 'reminder_type') then
    create type public.reminder_type as enum (
      'technical_inspection',  -- Contrôle technique
      'oil_change',            -- Vidange
      'general_maintenance',   -- Entretien général
      'custom'                 -- Personnalisé
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'document_type') then
    create type public.document_type as enum ('quote', 'invoice', 'report', 'photo_before', 'photo_after', 'other');
  end if;
end$$;

-- ----------------------------------------------------------------------------
-- 2. profiles — Extension de auth.users avec rôle applicatif
-- ----------------------------------------------------------------------------
create table if not exists public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  app_role      public.app_role not null default 'client',
  full_name     text,
  email         text,
  phone         text,
  avatar_url    text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index if not exists idx_profiles_app_role on public.profiles(app_role);

-- ----------------------------------------------------------------------------
-- 3. garage_settings — Singleton de configuration du garage
-- ----------------------------------------------------------------------------
create table if not exists public.garage_settings (
  id                      smallint primary key default 1 check (id = 1),
  name                    text not null default 'Mon Garage',
  address                 text,
  phone                   text,
  email                   text,
  timezone                text not null default 'Europe/Paris',
  -- Horaires : tableau JSON par jour, format { "monday": [{ "start": "08:00", "end": "17:30" }], ... }
  opening_hours           jsonb not null default '{
    "monday":    [{"start": "08:00", "end": "17:30"}],
    "tuesday":   [{"start": "08:00", "end": "17:30"}],
    "wednesday": [{"start": "08:00", "end": "17:30"}],
    "thursday":  [{"start": "08:00", "end": "17:30"}],
    "friday":    [{"start": "08:00", "end": "17:30"}],
    "saturday":  [],
    "sunday":    []
  }'::jsonb,
  slot_granularity_min    smallint not null default 30 check (slot_granularity_min in (15, 30, 60)),
  safety_margin_min       smallint not null default 10 check (safety_margin_min >= 0 and safety_margin_min <= 60),
  public_holidays         date[] not null default '{}',  -- Jours fériés où le garage est fermé
  workshop_capacity       smallint not null default 5 check (workshop_capacity > 0),  -- Nombre de places simultanées
  daily_sms_limit         smallint not null default 200,
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 4. specialties — Référentiel libre des spécialités
-- ----------------------------------------------------------------------------
create table if not exists public.specialties (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  color_hex   text default '#888780' check (color_hex ~ '^#[0-9A-Fa-f]{6}$'),
  description text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 5. mechanics — Les mécaniciens du garage
-- ----------------------------------------------------------------------------
create table if not exists public.mechanics (
  id              uuid primary key default gen_random_uuid(),
  profile_id      uuid unique references public.profiles(id) on delete set null,
  first_name      text not null,
  last_name       text not null,
  email           text unique,
  phone           text,
  color_hex       text not null default '#378ADD' check (color_hex ~ '^#[0-9A-Fa-f]{6}$'),
  hire_date       date,
  is_active       boolean not null default true,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists idx_mechanics_is_active on public.mechanics(is_active) where is_active = true;
create index if not exists idx_mechanics_profile_id on public.mechanics(profile_id);

-- ----------------------------------------------------------------------------
-- 6. mechanic_specialties — Liaison N:N
-- ----------------------------------------------------------------------------
create table if not exists public.mechanic_specialties (
  mechanic_id   uuid not null references public.mechanics(id) on delete cascade,
  specialty_id  uuid not null references public.specialties(id) on delete cascade,
  level         smallint default 1 check (level between 1 and 3),  -- 1 = junior, 2 = confirmé, 3 = expert
  created_at    timestamptz not null default now(),
  primary key (mechanic_id, specialty_id)
);

-- ----------------------------------------------------------------------------
-- 7. mechanic_schedules — Horaires de travail récurrents
-- ----------------------------------------------------------------------------
create table if not exists public.mechanic_schedules (
  id            uuid primary key default gen_random_uuid(),
  mechanic_id   uuid not null references public.mechanics(id) on delete cascade,
  day_of_week   smallint not null check (day_of_week between 0 and 6),  -- 0=dimanche, 1=lundi, ..., 6=samedi
  start_time    time not null,
  end_time      time not null,
  created_at    timestamptz not null default now(),
  check (start_time < end_time)
);

create index if not exists idx_mechanic_schedules_mechanic on public.mechanic_schedules(mechanic_id, day_of_week);

-- ----------------------------------------------------------------------------
-- 8. time_off — Congés et absences
-- ----------------------------------------------------------------------------
create table if not exists public.time_off (
  id            uuid primary key default gen_random_uuid(),
  mechanic_id   uuid not null references public.mechanics(id) on delete cascade,
  start_date    date not null,
  end_date      date not null,
  reason        text,
  approved      boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  check (start_date <= end_date)
);

create index if not exists idx_time_off_mechanic_dates on public.time_off(mechanic_id, start_date, end_date);

-- ----------------------------------------------------------------------------
-- 9. clients — Clients du garage
-- ----------------------------------------------------------------------------
create table if not exists public.clients (
  id              uuid primary key default gen_random_uuid(),
  profile_id      uuid unique references public.profiles(id) on delete set null,
  first_name      text not null,
  last_name       text not null,
  email           text,
  phone           text,
  address         text,
  city            text,
  postal_code     text,
  -- Préférences de contact
  sms_opt_in      boolean not null default true,
  email_opt_in    boolean not null default true,
  marketing_opt_in boolean not null default false,
  -- Type de client
  is_professional boolean not null default false,
  company_name    text,
  vat_number      text,
  notes           text,
  -- Anonymisation RGPD
  is_anonymized   boolean not null default false,
  anonymized_at   timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists idx_clients_email on public.clients(lower(email)) where email is not null;
create index if not exists idx_clients_phone on public.clients(phone) where phone is not null;
create index if not exists idx_clients_search on public.clients using gin ((first_name || ' ' || last_name) gin_trgm_ops);
create index if not exists idx_clients_profile on public.clients(profile_id);

-- ----------------------------------------------------------------------------
-- 10. vehicles — Véhicules
-- ----------------------------------------------------------------------------
create table if not exists public.vehicles (
  id                          uuid primary key default gen_random_uuid(),
  client_id                   uuid not null references public.clients(id) on delete cascade,
  license_plate               text not null,
  brand                       text not null,
  model                       text not null,
  year                        smallint check (year between 1900 and extract(year from now())::int + 1),
  fuel_type                   text check (fuel_type in ('petrol', 'diesel', 'electric', 'hybrid', 'lpg', 'other')),
  mileage_km                  integer check (mileage_km >= 0),
  mileage_updated_at          timestamptz,
  vin                         text,
  color                       text,
  -- Dates de référence pour les rappels
  last_technical_inspection   date,
  next_technical_inspection   date,
  last_oil_change_date        date,
  last_oil_change_km          integer,
  notes                       text,
  created_at                  timestamptz not null default now(),
  updated_at                  timestamptz not null default now()
);

create index if not exists idx_vehicles_client on public.vehicles(client_id);
create unique index if not exists idx_vehicles_license_plate on public.vehicles(upper(replace(license_plate, ' ', '')));
create index if not exists idx_vehicles_next_inspection on public.vehicles(next_technical_inspection) where next_technical_inspection is not null;

-- ----------------------------------------------------------------------------
-- 11. intervention_types — Catalogue des types d'intervention
-- ----------------------------------------------------------------------------
create table if not exists public.intervention_types (
  id                      uuid primary key default gen_random_uuid(),
  name                    text not null unique,
  description             text,
  default_duration_min    smallint not null check (default_duration_min > 0),
  default_price_eur       numeric(10, 2) check (default_price_eur >= 0),
  requires_approval       boolean not null default false,
  color_hex               text default '#888780' check (color_hex ~ '^#[0-9A-Fa-f]{6}$'),
  is_active               boolean not null default true,
  sort_order              smallint not null default 0,
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now()
);

create index if not exists idx_intervention_types_active on public.intervention_types(is_active, sort_order) where is_active = true;

-- ----------------------------------------------------------------------------
-- 12. intervention_type_specialties — Spécialités requises par type
-- ----------------------------------------------------------------------------
create table if not exists public.intervention_type_specialties (
  intervention_type_id  uuid not null references public.intervention_types(id) on delete cascade,
  specialty_id          uuid not null references public.specialties(id) on delete cascade,
  is_required           boolean not null default true,  -- false = "préférable"
  primary key (intervention_type_id, specialty_id)
);

-- ----------------------------------------------------------------------------
-- 13. interventions — Cœur métier
-- ----------------------------------------------------------------------------
create table if not exists public.interventions (
  id                      uuid primary key default gen_random_uuid(),
  client_id               uuid not null references public.clients(id) on delete restrict,
  vehicle_id              uuid not null references public.vehicles(id) on delete restrict,
  intervention_type_id    uuid not null references public.intervention_types(id) on delete restrict,
  mechanic_id             uuid references public.mechanics(id) on delete set null,
  -- Planning
  scheduled_start         timestamptz,
  scheduled_end           timestamptz,
  -- Exécution réelle
  actual_start            timestamptz,
  actual_end              timestamptz,
  -- Statut
  status                  public.intervention_status not null default 'pending_approval',
  -- Détails
  client_notes            text,         -- Saisi par le client lors de la demande
  internal_notes          text,         -- Visible staff uniquement
  client_visible_notes    text,         -- Notes visibles côté client
  -- Tarif réel facturé (peut différer du prix par défaut du type)
  final_price_eur         numeric(10, 2) check (final_price_eur is null or final_price_eur >= 0),
  -- Kilométrage du véhicule au moment de l'intervention
  vehicle_mileage_km      integer check (vehicle_mileage_km is null or vehicle_mileage_km >= 0),
  -- Métadonnées
  created_by              uuid references auth.users(id) on delete set null,
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now(),
  -- Cohérence horaires planifiés
  check (scheduled_start is null or scheduled_end is null or scheduled_start < scheduled_end),
  -- Cohérence horaires réels
  check (actual_start is null or actual_end is null or actual_start <= actual_end)
);

-- Index critiques pour les performances du planning
create index if not exists idx_interventions_scheduled_start on public.interventions(scheduled_start);
create index if not exists idx_interventions_mechanic_schedule on public.interventions(mechanic_id, scheduled_start, scheduled_end);
create index if not exists idx_interventions_client on public.interventions(client_id);
create index if not exists idx_interventions_vehicle on public.interventions(vehicle_id);
create index if not exists idx_interventions_status on public.interventions(status);
create index if not exists idx_interventions_pending on public.interventions(created_at desc) where status = 'pending_approval';
create index if not exists idx_interventions_today on public.interventions(scheduled_start)
  where status in ('scheduled', 'in_progress', 'on_hold');

-- ----------------------------------------------------------------------------
-- 14. intervention_status_log — Audit log des changements de statut
-- ----------------------------------------------------------------------------
create table if not exists public.intervention_status_log (
  id                uuid primary key default gen_random_uuid(),
  intervention_id   uuid not null references public.interventions(id) on delete cascade,
  from_status       public.intervention_status,
  to_status         public.intervention_status not null,
  changed_by        uuid references auth.users(id) on delete set null,
  reason            text,
  changed_at        timestamptz not null default now()
);

create index if not exists idx_status_log_intervention on public.intervention_status_log(intervention_id, changed_at desc);

-- ----------------------------------------------------------------------------
-- 15. documents — Fichiers attachés aux interventions
-- ----------------------------------------------------------------------------
create table if not exists public.documents (
  id                uuid primary key default gen_random_uuid(),
  intervention_id   uuid not null references public.interventions(id) on delete cascade,
  storage_path      text not null,  -- chemin dans Supabase Storage
  document_type     public.document_type not null default 'other',
  label             text,
  file_size_bytes   bigint,
  mime_type         text,
  is_client_visible boolean not null default true,
  uploaded_by       uuid references auth.users(id) on delete set null,
  created_at        timestamptz not null default now()
);

create index if not exists idx_documents_intervention on public.documents(intervention_id);

-- ----------------------------------------------------------------------------
-- 16. reviews — Avis clients
-- ----------------------------------------------------------------------------
create table if not exists public.reviews (
  id                uuid primary key default gen_random_uuid(),
  intervention_id   uuid not null unique references public.interventions(id) on delete cascade,
  client_id         uuid not null references public.clients(id) on delete cascade,
  rating            smallint not null check (rating between 1 and 5),
  comment           text,
  is_published      boolean not null default true,
  admin_reply       text,
  admin_reply_at    timestamptz,
  created_at        timestamptz not null default now()
);

create index if not exists idx_reviews_published on public.reviews(created_at desc) where is_published = true;
create index if not exists idx_reviews_intervention on public.reviews(intervention_id);

-- ----------------------------------------------------------------------------
-- 17. notifications — Journal des notifications envoyées
-- ----------------------------------------------------------------------------
create table if not exists public.notifications (
  id                uuid primary key default gen_random_uuid(),
  client_id         uuid references public.clients(id) on delete cascade,
  intervention_id   uuid references public.interventions(id) on delete cascade,
  channel           public.notification_channel not null,
  template          text not null,  -- ex: 'rdv_confirmation', 'rappel_j_moins_1'
  recipient         text not null,  -- email ou téléphone
  subject           text,
  body_preview      text,           -- premiers 200 chars du body pour debug
  status            public.notification_status not null default 'queued',
  error_message     text,
  external_id       text,           -- ID Resend/Brevo pour traçabilité
  sent_at           timestamptz,
  created_at        timestamptz not null default now()
);

create index if not exists idx_notifications_client on public.notifications(client_id, created_at desc);
create index if not exists idx_notifications_intervention on public.notifications(intervention_id, created_at desc);
create index if not exists idx_notifications_status on public.notifications(status, created_at desc);
create index if not exists idx_notifications_daily_sms on public.notifications(sent_at)
  where channel = 'sms' and status = 'sent';

-- ----------------------------------------------------------------------------
-- 18. maintenance_reminders — Rappels périodiques par véhicule
-- ----------------------------------------------------------------------------
create table if not exists public.maintenance_reminders (
  id              uuid primary key default gen_random_uuid(),
  vehicle_id      uuid not null references public.vehicles(id) on delete cascade,
  reminder_type   public.reminder_type not null,
  due_date        date,
  due_mileage_km  integer,
  message         text,
  -- Statut d'envoi
  notified_at     timestamptz,
  is_dismissed    boolean not null default false,
  -- Récurrence
  is_recurring    boolean not null default true,
  recurrence_months smallint,  -- ex: 24 pour CT
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  check (due_date is not null or due_mileage_km is not null)
);

create index if not exists idx_reminders_due on public.maintenance_reminders(due_date)
  where notified_at is null and is_dismissed = false;
create index if not exists idx_reminders_vehicle on public.maintenance_reminders(vehicle_id);

-- ----------------------------------------------------------------------------
-- 19. google_tokens — Tokens OAuth Google par mécanicien
-- ----------------------------------------------------------------------------
create table if not exists public.google_tokens (
  id                uuid primary key default gen_random_uuid(),
  mechanic_id       uuid not null unique references public.mechanics(id) on delete cascade,
  access_token      text not null,    -- À chiffrer côté application via Supabase Vault si possible
  refresh_token     text not null,
  expires_at        timestamptz not null,
  calendar_id       text not null default 'primary',
  watch_channel_id  text,              -- ID du webhook Google Calendar
  watch_resource_id text,
  watch_expires_at  timestamptz,
  last_sync_at      timestamptz,
  sync_token        text,              -- Pour les sync incrémentales Google
  is_active         boolean not null default true,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index if not exists idx_google_tokens_active on public.google_tokens(mechanic_id) where is_active = true;
create index if not exists idx_google_tokens_expiring on public.google_tokens(expires_at) where is_active = true;

-- ----------------------------------------------------------------------------
-- 20. magic_link_tokens — Tokens pour accès client sans compte
-- ----------------------------------------------------------------------------
create table if not exists public.magic_link_tokens (
  id            uuid primary key default gen_random_uuid(),
  client_id     uuid not null references public.clients(id) on delete cascade,
  token_hash    text not null unique,  -- SHA-256 du token, jamais le token brut
  purpose       text not null default 'client_access',
  expires_at    timestamptz not null,
  used_at       timestamptz,
  revoked_at    timestamptz,
  created_at    timestamptz not null default now()
);

create index if not exists idx_magic_tokens_lookup on public.magic_link_tokens(token_hash) where used_at is null and revoked_at is null;
create index if not exists idx_magic_tokens_client on public.magic_link_tokens(client_id, created_at desc);

-- ============================================================================
-- FIN — Migration 01 : Schéma complet
-- ============================================================================
-- Prochaine étape : exécuter 02_functions_triggers.sql
-- ============================================================================
