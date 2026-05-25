import { type NextRequest, NextResponse } from 'next/server';

import { updateSession } from '@/lib/supabase/middleware';

/**
 * Préfixes de routes par espace.
 * Cohérent avec la structure de dossiers src/app/(admin), (mecanicien), (client).
 */
const ADMIN_ROUTES = [
  '/tableau-de-bord',
  '/planning',
  '/demandes',
  '/mecaniciens',
  '/clients',
  '/vehicules',
  '/types-intervention',
  '/parametres',
  '/rapports',
];

const MECHANIC_ROUTES = ['/mon-planning', '/intervention', '/historique', '/mon-google'];

const CLIENT_ROUTES = ['/espace', '/mes-rendez-vous', '/mes-vehicules', '/mes-documents'];

const PUBLIC_AUTH_ROUTES = ['/connexion', '/inscription-client', '/lien-magique'];

function pathStartsWithAny(pathname: string, prefixes: string[]): boolean {
  return prefixes.some((prefix) => pathname === prefix || pathname.startsWith(prefix + '/'));
}

export async function middleware(request: NextRequest) {
  const { response, user } = await updateSession(request);
  const pathname = request.nextUrl.pathname;

  // Récupère le rôle depuis le JWT (app_metadata.app_role)
  // S'il n'est pas présent, on tombera dans les redirections de garde
  const appRole = user
    ? ((user.app_metadata?.app_role as string | undefined) ?? null)
    : null;

  const isAdminRoute = pathStartsWithAny(pathname, ADMIN_ROUTES);
  const isMechanicRoute = pathStartsWithAny(pathname, MECHANIC_ROUTES);
  const isClientRoute = pathStartsWithAny(pathname, CLIENT_ROUTES);
  const isAuthRoute = pathStartsWithAny(pathname, PUBLIC_AUTH_ROUTES);
  const isProtectedRoute = isAdminRoute || isMechanicRoute || isClientRoute;

  // 1. Route protégée mais user non authentifié → /connexion
  if (isProtectedRoute && !user) {
    const url = request.nextUrl.clone();
    url.pathname = '/connexion';
    url.searchParams.set('next', pathname);
    return NextResponse.redirect(url);
  }

  // 2. User authentifié sur /connexion → redirection vers son espace
  if (user && isAuthRoute) {
    const url = request.nextUrl.clone();
    if (appRole === 'admin') url.pathname = '/tableau-de-bord';
    else if (appRole === 'mechanic') url.pathname = '/mon-planning';
    else if (appRole === 'client') url.pathname = '/espace';
    else url.pathname = '/';
    return NextResponse.redirect(url);
  }

  // 3. Vérification des permissions par rôle sur les routes protégées
  if (user && isProtectedRoute) {
    if (isAdminRoute && appRole !== 'admin') {
      return redirectToOwnSpace(request, appRole);
    }
    if (isMechanicRoute && appRole !== 'mechanic') {
      return redirectToOwnSpace(request, appRole);
    }
    if (isClientRoute && appRole !== 'client') {
      return redirectToOwnSpace(request, appRole);
    }
  }

  return response;
}

function redirectToOwnSpace(request: NextRequest, role: string | null): NextResponse {
  const url = request.nextUrl.clone();
  if (role === 'admin') url.pathname = '/tableau-de-bord';
  else if (role === 'mechanic') url.pathname = '/mon-planning';
  else if (role === 'client') url.pathname = '/espace';
  else url.pathname = '/';
  return NextResponse.redirect(url);
}

export const config = {
  // Match toutes les routes SAUF les assets statiques et les routes API d'auth callback
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};
