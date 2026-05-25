/**
 * Types Supabase générés automatiquement
 *
 * Ce fichier sera regénéré par : pnpm supabase:types
 * Pour l'instant (S0), on définit un type minimal pour faire compiler.
 *
 * Pour générer le vrai fichier complet :
 *   1. Installer Supabase CLI : npm install -g supabase
 *   2. Récupérer le project ref dans Supabase Dashboard → Settings → General → Reference ID
 *   3. Modifier le script "supabase:types" dans package.json avec ce ref
 *   4. Lancer : pnpm supabase:types
 *
 * Ce type sera ensuite utilisé par createClient<Database>() pour bénéficier
 * de l'autocomplétion et de la sécurité de type sur toute la base.
 */

export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];

export interface Database {
  public: {
    Tables: Record<string, { Row: Record<string, unknown>; Insert: Record<string, unknown>; Update: Record<string, unknown> }>;
    Views: Record<string, { Row: Record<string, unknown> }>;
    Functions: Record<string, { Args: Record<string, unknown>; Returns: unknown }>;
    Enums: {
      app_role: 'admin' | 'mechanic' | 'client';
      intervention_status:
        | 'pending_approval'
        | 'scheduled'
        | 'in_progress'
        | 'on_hold'
        | 'completed'
        | 'delivered'
        | 'cancelled'
        | 'no_show';
      notification_channel: 'email' | 'sms';
      notification_status: 'queued' | 'sent' | 'failed' | 'skipped';
      reminder_type: 'technical_inspection' | 'oil_change' | 'general_maintenance' | 'custom';
      document_type: 'quote' | 'invoice' | 'report' | 'photo_before' | 'photo_after' | 'other';
    };
  };
}
