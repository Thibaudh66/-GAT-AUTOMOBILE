'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

import { getDefaultRouteForRole } from '@/lib/auth/get-current-user';
import { createClient } from '@/lib/supabase/server';
import { loginSchema } from '@/lib/validations/auth';
import type { ActionResult, AppRole } from '@/types/domain';

export async function loginAction(
  _prevState: ActionResult<{ redirectTo: string }> | null,
  formData: FormData,
): Promise<ActionResult<{ redirectTo: string }>> {
  // 1. Validation
  const parsed = loginSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
  });

  if (!parsed.success) {
    return {
      ok: false,
      error: parsed.error.issues[0]?.message ?? 'Données invalides',
      code: 'VALIDATION',
    };
  }

  // 2. Connexion via Supabase Auth
  const supabase = createClient();
  const { data, error } = await supabase.auth.signInWithPassword({
    email: parsed.data.email,
    password: parsed.data.password,
  });

  if (error || !data.user) {
    return {
      ok: false,
      error: 'Email ou mot de passe incorrect',
      code: 'FORBIDDEN',
    };
  }

  // 3. Récupération du rôle pour rediriger
  const role = (data.user.app_metadata?.app_role as AppRole | undefined) ?? null;

  const next = (formData.get('next') as string | null) ?? null;
  const redirectTo = next && next.startsWith('/') ? next : getDefaultRouteForRole(role ?? 'client');

  revalidatePath('/', 'layout');

  // 4. Redirection serveur (jamais à l'utilisateur de fabriquer une URL)
  redirect(redirectTo);
}
