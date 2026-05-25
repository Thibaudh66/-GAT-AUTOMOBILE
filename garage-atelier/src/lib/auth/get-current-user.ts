import { createClient } from '@/lib/supabase/server';
import type { AppRole, Profile } from '@/types/domain';

/**
 * Récupère l'utilisateur authentifié et son profil applicatif.
 *
 * À utiliser dans les Server Components et Server Actions pour vérifier
 * l'identité ET le rôle métier.
 *
 * Retourne null si non authentifié ou si pas de profil associé.
 */
export async function getCurrentUser(): Promise<{
  userId: string;
  email: string;
  profile: Profile;
} | null> {
  const supabase = createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return null;
  }

  const { data: profile, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single<Profile>();

  if (error || !profile) {
    return null;
  }

  return {
    userId: user.id,
    email: user.email ?? '',
    profile,
  };
}

/**
 * Vérifie que l'utilisateur courant a un des rôles autorisés.
 *
 * Lance une erreur sinon. À utiliser en haut des Server Actions sensibles :
 *
 *   await requireRole(['admin'])
 */
export async function requireRole(allowedRoles: AppRole[]): Promise<Profile> {
  const user = await getCurrentUser();

  if (!user) {
    throw new Error('UNAUTHENTICATED');
  }

  if (!allowedRoles.includes(user.profile.app_role)) {
    throw new Error('FORBIDDEN');
  }

  return user.profile;
}

/**
 * Détermine l'URL de redirection par défaut selon le rôle.
 *
 * Utilisé après login ou pour rediriger un user déjà connecté qui visite /connexion.
 */
export function getDefaultRouteForRole(role: AppRole): string {
  switch (role) {
    case 'admin':
      return '/tableau-de-bord';
    case 'mechanic':
      return '/mon-planning';
    case 'client':
      return '/espace';
    default:
      return '/';
  }
}
