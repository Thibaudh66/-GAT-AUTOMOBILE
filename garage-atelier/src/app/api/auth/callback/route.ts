import { NextResponse } from 'next/server';

import { createClient } from '@/lib/supabase/server';

/**
 * Route de callback OAuth Supabase.
 *
 * Utilisée pour les magic links (sprint S5) et les futurs providers OAuth.
 * En S0 le code n'est pas encore utilisé mais doit être présent.
 */
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get('code');
  const next = searchParams.get('next') ?? '/';

  if (code) {
    const supabase = createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);

    if (!error) {
      return NextResponse.redirect(`${origin}${next}`);
    }
  }

  return NextResponse.redirect(`${origin}/connexion?error=auth_callback_failed`);
}
