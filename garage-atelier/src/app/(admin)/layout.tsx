import Link from 'next/link';
import { redirect } from 'next/navigation';

import { LogoutButton } from '@/components/layout/logout-button';
import { getCurrentUser } from '@/lib/auth/get-current-user';

const adminNav = [
  { href: '/tableau-de-bord', label: 'Tableau de bord' },
  { href: '/planning', label: 'Planning' },
  { href: '/demandes', label: 'Demandes' },
  { href: '/mecaniciens', label: 'Mécaniciens' },
  { href: '/clients', label: 'Clients' },
  { href: '/vehicules', label: 'Véhicules' },
  { href: '/types-intervention', label: 'Types d’intervention' },
  { href: '/parametres/garage', label: 'Paramètres' },
];

export default async function AdminLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const user = await getCurrentUser();

  if (!user) {
    redirect('/connexion');
  }

  if (user.profile.app_role !== 'admin') {
    redirect('/');
  }

  const garageName = process.env.NEXT_PUBLIC_GARAGE_NAME ?? 'Garage Atelier';

  return (
    <div className="flex min-h-screen flex-col bg-muted/30">
      {/* Topbar */}
      <header className="border-b bg-background">
        <div className="container flex h-14 items-center justify-between">
          <div className="flex items-center gap-2">
            <Link href="/tableau-de-bord" className="font-semibold">
              {garageName}
            </Link>
            <span className="rounded-md bg-primary/10 px-2 py-0.5 text-xs font-medium text-primary">
              Admin
            </span>
          </div>
          <div className="flex items-center gap-4 text-sm">
            <span className="text-muted-foreground">{user.profile.full_name ?? user.email}</span>
            <LogoutButton />
          </div>
        </div>
      </header>

      <div className="container flex flex-1 gap-6 py-6">
        {/* Sidebar */}
        <aside className="w-56 shrink-0">
          <nav className="space-y-1 text-sm">
            {adminNav.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="block rounded-md px-3 py-2 hover:bg-accent"
              >
                {item.label}
              </Link>
            ))}
          </nav>
        </aside>

        {/* Content */}
        <main className="flex-1">{children}</main>
      </div>
    </div>
  );
}
