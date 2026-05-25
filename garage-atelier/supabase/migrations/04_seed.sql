-- ============================================================================
-- GARAGE ATELIER — Migration 04 : Données initiales
-- ============================================================================
-- À exécuter APRÈS 03_rls_policies.sql
-- Ce fichier crée les données minimales pour que l'app démarre :
--   - paramètres garage par défaut
--   - spécialités courantes
--   - types d'intervention courants
--   - quelques mécaniciens d'exemple
--   - quelques clients/véhicules d'exemple (à supprimer en production)
-- ============================================================================
-- IMPORTANT : Pour créer les utilisateurs auth (admin, mécaniciens), il faut
-- passer par le dashboard Supabase : Authentication → Users → Add user
-- Puis venir mettre à jour leur app_role et lier leurs profile_id ici.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Paramètres garage (singleton)
-- ----------------------------------------------------------------------------
insert into public.garage_settings (id, name, address, phone, email, timezone)
values (
  1,
  'Garage Atelier',
  'À configurer',
  '+33 4 00 00 00 00',
  'contact@garage.fr',
  'Europe/Paris'
)
on conflict (id) do nothing;

-- ----------------------------------------------------------------------------
-- 2. Spécialités courantes (libres, modifiables par admin)
-- ----------------------------------------------------------------------------
insert into public.specialties (name, color_hex, description) values
  ('Mécanique générale',  '#185FA5', 'Entretien courant, vidange, freins, suspension'),
  ('Carrosserie',         '#993C1D', 'Réparation tôle, peinture, débosselage'),
  ('Électronique',        '#534AB7', 'Diagnostic OBD, électronique embarquée'),
  ('Climatisation',       '#0F6E56', 'Recharge clim, diagnostic circuit froid'),
  ('Pneumatiques',        '#854F0B', 'Montage, équilibrage, parallélisme'),
  ('Distribution',        '#A32D2D', 'Courroie/chaîne de distribution'),
  ('Moteur',              '#3B6D11', 'Démontage moteur, embrayage, joint culasse')
on conflict (name) do nothing;

-- ----------------------------------------------------------------------------
-- 3. Types d'intervention courants
-- ----------------------------------------------------------------------------
insert into public.intervention_types (
  name, description, default_duration_min, default_price_eur, requires_approval, color_hex, sort_order
) values
  -- Interventions rapides, sans validation
  ('Vidange + filtre à huile',     'Vidange moteur et remplacement du filtre',                  60,   89.00, false, '#1D9E75', 10),
  ('Contrôle technique préparation', 'Vérification avant passage au CT',                         45,   49.00, false, '#1D9E75', 20),
  ('Montage pneus (4)',            'Montage et équilibrage de 4 pneus',                         90,   60.00, false, '#1D9E75', 30),
  ('Recharge climatisation',       'Recharge gaz et contrôle circuit',                          60,  120.00, false, '#1D9E75', 40),
  ('Remplacement plaquettes AV',   'Plaquettes de frein avant',                                 60,   80.00, false, '#1D9E75', 50),
  ('Diagnostic électronique',      'Lecture défauts OBD et diagnostic',                         45,   55.00, false, '#1D9E75', 60),

  -- Interventions plus longues, avec validation admin
  ('Embrayage',                     'Remplacement embrayage complet',                          480,  650.00, true,  '#BA7517', 100),
  ('Distribution',                  'Kit distribution + pompe à eau',                          360,  550.00, true,  '#BA7517', 110),
  ('Joint de culasse',              'Diagnostic + réparation joint de culasse',                720, 1200.00, true,  '#BA7517', 120),
  ('Carrosserie devis',             'Diagnostic carrosserie et établissement devis',            60,    0.00, true,  '#993C1D', 130),
  ('Autre / À diagnostiquer',       'Intervention non listée, à diagnostiquer',                 60,    0.00, true,  '#888780', 200)
on conflict (name) do nothing;

-- ----------------------------------------------------------------------------
-- 4. Associations types ↔ spécialités requises
-- ----------------------------------------------------------------------------
-- Vidange → Mécanique générale
insert into public.intervention_type_specialties (intervention_type_id, specialty_id, is_required)
select it.id, s.id, true
from public.intervention_types it, public.specialties s
where it.name = 'Vidange + filtre à huile' and s.name = 'Mécanique générale'
on conflict do nothing;

-- Embrayage → Moteur
insert into public.intervention_type_specialties (intervention_type_id, specialty_id, is_required)
select it.id, s.id, true
from public.intervention_types it, public.specialties s
where it.name = 'Embrayage' and s.name = 'Moteur'
on conflict do nothing;

-- Distribution → Distribution
insert into public.intervention_type_specialties (intervention_type_id, specialty_id, is_required)
select it.id, s.id, true
from public.intervention_types it, public.specialties s
where it.name = 'Distribution' and s.name = 'Distribution'
on conflict do nothing;

-- Joint de culasse → Moteur
insert into public.intervention_type_specialties (intervention_type_id, specialty_id, is_required)
select it.id, s.id, true
from public.intervention_types it, public.specialties s
where it.name = 'Joint de culasse' and s.name = 'Moteur'
on conflict do nothing;

-- Carrosserie → Carrosserie
insert into public.intervention_type_specialties (intervention_type_id, specialty_id, is_required)
select it.id, s.id, true
from public.intervention_types it, public.specialties s
where it.name = 'Carrosserie devis' and s.name = 'Carrosserie'
on conflict do nothing;

-- Diagnostic électronique → Électronique
insert into public.intervention_type_specialties (intervention_type_id, specialty_id, is_required)
select it.id, s.id, true
from public.intervention_types it, public.specialties s
where it.name = 'Diagnostic électronique' and s.name = 'Électronique'
on conflict do nothing;

-- Recharge clim → Climatisation
insert into public.intervention_type_specialties (intervention_type_id, specialty_id, is_required)
select it.id, s.id, true
from public.intervention_types it, public.specialties s
where it.name = 'Recharge climatisation' and s.name = 'Climatisation'
on conflict do nothing;

-- Pneus → Pneumatiques
insert into public.intervention_type_specialties (intervention_type_id, specialty_id, is_required)
select it.id, s.id, true
from public.intervention_types it, public.specialties s
where it.name = 'Montage pneus (4)' and s.name = 'Pneumatiques'
on conflict do nothing;

-- Plaquettes → Mécanique générale
insert into public.intervention_type_specialties (intervention_type_id, specialty_id, is_required)
select it.id, s.id, true
from public.intervention_types it, public.specialties s
where it.name = 'Remplacement plaquettes AV' and s.name = 'Mécanique générale'
on conflict do nothing;

-- ----------------------------------------------------------------------------
-- 5. Mécaniciens d'exemple (à remplacer par les vrais)
-- ----------------------------------------------------------------------------
-- Ces lignes créent des mécanos SANS profile_id (donc sans compte de connexion).
-- Pour les rendre fonctionnels :
--   1. Créer un user dans Authentication → Users (mot de passe staff)
--   2. Mettre à jour son profile : update public.profiles set app_role = 'mechanic' where id = '...'
--   3. Lier le mécanicien : update public.mechanics set profile_id = '...' where id = '...'
insert into public.mechanics (id, first_name, last_name, color_hex, hire_date, is_active) values
  ('11111111-1111-1111-1111-111111111111', 'Jean',    'Martin',  '#185FA5', '2018-03-15', true),
  ('22222222-2222-2222-2222-222222222222', 'Sophie',  'Bernard', '#993C1D', '2020-09-01', true),
  ('33333333-3333-3333-3333-333333333333', 'Karim',   'Dubois',  '#0F6E56', '2022-01-10', true)
on conflict (id) do nothing;

-- Spécialités des mécanos exemples
-- Jean : Mécanique générale (expert) + Distribution
insert into public.mechanic_specialties (mechanic_id, specialty_id, level)
select '11111111-1111-1111-1111-111111111111', s.id, 3 from public.specialties s where s.name = 'Mécanique générale'
on conflict do nothing;
insert into public.mechanic_specialties (mechanic_id, specialty_id, level)
select '11111111-1111-1111-1111-111111111111', s.id, 2 from public.specialties s where s.name = 'Distribution'
on conflict do nothing;
insert into public.mechanic_specialties (mechanic_id, specialty_id, level)
select '11111111-1111-1111-1111-111111111111', s.id, 2 from public.specialties s where s.name = 'Moteur'
on conflict do nothing;

-- Sophie : Carrosserie (expert)
insert into public.mechanic_specialties (mechanic_id, specialty_id, level)
select '22222222-2222-2222-2222-222222222222', s.id, 3 from public.specialties s where s.name = 'Carrosserie'
on conflict do nothing;

-- Karim : Électronique + Climatisation
insert into public.mechanic_specialties (mechanic_id, specialty_id, level)
select '33333333-3333-3333-3333-333333333333', s.id, 3 from public.specialties s where s.name = 'Électronique'
on conflict do nothing;
insert into public.mechanic_specialties (mechanic_id, specialty_id, level)
select '33333333-3333-3333-3333-333333333333', s.id, 2 from public.specialties s where s.name = 'Climatisation'
on conflict do nothing;
insert into public.mechanic_specialties (mechanic_id, specialty_id, level)
select '33333333-3333-3333-3333-333333333333', s.id, 2 from public.specialties s where s.name = 'Pneumatiques'
on conflict do nothing;

-- ----------------------------------------------------------------------------
-- 6. Horaires de travail des mécanos (lun-ven 8h-12h / 13h30-17h30)
-- ----------------------------------------------------------------------------
-- Pause déjeuner gérée comme 2 plages distinctes
do $$
declare
  m_id uuid;
  d smallint;
begin
  for m_id in select id from public.mechanics where is_active = true loop
    for d in 1..5 loop  -- 1=lundi à 5=vendredi
      insert into public.mechanic_schedules (mechanic_id, day_of_week, start_time, end_time)
      values
        (m_id, d, '08:00', '12:00'),
        (m_id, d, '13:30', '17:30')
      on conflict do nothing;
    end loop;
  end loop;
end$$;

-- ----------------------------------------------------------------------------
-- 7. Clients d'exemple (à supprimer en production)
-- ----------------------------------------------------------------------------
-- Pour activer en dev, dé-commenter le bloc ci-dessous. À NE PAS exécuter en prod.

/*
insert into public.clients (id, first_name, last_name, email, phone, address, city, postal_code, sms_opt_in, email_opt_in) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Marie',  'Lefèvre', 'marie.lefevre@example.com',  '+33612345678', '12 rue de la Paix', 'Marseille', '13001', true, true),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Pierre', 'Moreau',  'pierre.moreau@example.com',  '+33623456789', '45 av. Foch',       'Marseille', '13006', true, true),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Anne',   'Petit',   'anne.petit@example.com',     '+33634567890', '8 bd Notre-Dame',   'Marseille', '13007', false, true)
on conflict (id) do nothing;

insert into public.vehicles (id, client_id, license_plate, brand, model, year, fuel_type, mileage_km, last_technical_inspection, next_technical_inspection) values
  ('11aaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'AB-123-CD', 'Peugeot',   '208',    2018, 'petrol', 85000,  '2024-01-15', '2026-01-15'),
  ('22aaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'EF-456-GH', 'Renault',   'Clio',   2020, 'diesel', 62000,  '2024-09-10', '2026-09-10'),
  ('33bbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'IJ-789-KL', 'Volkswagen','Golf',   2019, 'diesel', 120000, '2023-05-20', '2025-05-20'),
  ('44cccccc-cccc-cccc-cccc-cccccccccccc', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'MN-012-OP', 'Citroën',   'C3',     2021, 'petrol', 35000,  '2025-03-12', '2027-03-12')
on conflict (id) do nothing;
*/

-- ============================================================================
-- FIN — Migration 04 : Seed
-- ============================================================================
-- Pour créer un admin :
--   1. Authentication → Users → Add user (email + password)
--   2. SQL Editor : update public.profiles set app_role = 'admin' where email = 'admin@garage.fr';
--   3. Optionnel : update auth.users set raw_app_meta_data = raw_app_meta_data || '{"app_role":"admin"}' where email = 'admin@garage.fr';
-- ============================================================================
