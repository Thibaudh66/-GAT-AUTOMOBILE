import { createClient as createSupabaseClient } from '@supabase/supabase-js';

import type { Database } from '@/types/database.types';

/**
 * Client Supabase avec service_role — BYPASSE TOUTES LES POLICIES RLS.
 *
 * Usage strict :
 *   - Server Actions privilégiées (création de magic links, anonymisation, etc.)
 *   - Edge Functions
 *   - Webhooks de tiers (Google Calendar, Brevo, Resend)
 *
 * NE JAMAIS exposer ce client côté navigateur. NE JAMAIS importer ce fichier
 * depuis un Client Component (use client) — ça déclencherait une erreur de build.
 *
 * Si vous l'utilisez dans une Server Action, validez TOUJOURS les permissions
 * du user appelant en parallèle avec un client server normal.
 */
export function createAdminClient() {
  if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error('SUPABASE_SERVICE_ROLE_KEY is not set');
  }

  return createSupabaseClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    },
  );
}
