import { cookies } from 'next/headers';

import { createServerClient, type CookieOptions } from '@supabase/ssr';

import type { Database } from '@/types/database.types';

/**
 * Client Supabase pour les Server Components, Server Actions et Route Handlers.
 *
 * Gère automatiquement la lecture et le rafraîchissement du cookie de session.
 *
 * IMPORTANT : ne fonctionne QUE dans le contexte d'une requête Next.js.
 * Pour un job Edge Function autonome, voir admin.ts (service_role).
 */
export function createClient() {
  const cookieStore = cookies();

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet: { name: string; value: string; options?: CookieOptions }[]) {
          try {
            cookiesToSet.forEach(({ name, value, options }) => {
              cookieStore.set(name, value, options);
            });
          } catch {
            /*
             * setAll échoue dans les Server Components purs car on ne peut
             * pas y écrire de cookies. On l'ignore : le rafraîchissement
             * sera géré par le middleware au prochain cycle.
             */
          }
        },
      },
    },
  );
}
