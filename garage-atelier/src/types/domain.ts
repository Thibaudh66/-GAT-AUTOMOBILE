/**
 * Types métier de l'application Garage Atelier
 *
 * Ces types reflètent les ENUMs et structures principales de la base PostgreSQL.
 * Pour une génération automatique complète, voir :
 *   pnpm supabase:types (nécessite Supabase CLI)
 *
 * Au sprint S0, on définit uniquement les types nécessaires à l'authentification.
 */

export type AppRole = 'admin' | 'mechanic' | 'client';

export type InterventionStatus =
  | 'pending_approval'
  | 'scheduled'
  | 'in_progress'
  | 'on_hold'
  | 'completed'
  | 'delivered'
  | 'cancelled'
  | 'no_show';

export type NotificationChannel = 'email' | 'sms';

export type DocumentType =
  | 'quote'
  | 'invoice'
  | 'report'
  | 'photo_before'
  | 'photo_after'
  | 'other';

export interface Profile {
  id: string;
  app_role: AppRole;
  full_name: string | null;
  email: string | null;
  phone: string | null;
  avatar_url: string | null;
  created_at: string;
  updated_at: string;
}

/** Résultat standard de toute Server Action */
export type ActionResult<T = unknown> =
  | { ok: true; data: T }
  | { ok: false; error: string; code?: ActionErrorCode };

export type ActionErrorCode = 'VALIDATION' | 'FORBIDDEN' | 'NOT_FOUND' | 'CONFLICT' | 'INTERNAL';
