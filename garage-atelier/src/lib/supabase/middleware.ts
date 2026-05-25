import { createServerClient } from '@supabase/ssr';
import { type NextRequest, NextResponse } from 'next/server';

import type { Database } from '@/types/database.types';

/**
 * Met à jour le cookie de session Supabase à chaque requête.
 *
 * Renvoie également la response avec les cookies mis à jour, à utiliser
 * dans le middleware racine.
 */
export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({
    request,
  });

  const supabase = createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
          response = NextResponse.next({
            request,
          });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options),
          );
        },
      },
    },
  );

  // Force le rafraîchissement de la session expirée
  // IMPORTANT : getUser() est utilisé plutôt que getSession() pour des raisons de sécurité.
  // getSession() lit le cookie sans validation côté Supabase.
  const {
    data: { user },
  } = await supabase.auth.getUser();

  return { response, user };
}
