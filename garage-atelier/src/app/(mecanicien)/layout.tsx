import Link from 'next/link';
import { redirect } from 'next/navigation';

import { LogoutButton } from '@/components/layout/logout-button';
import { getCurrentUser } from '@/lib/auth/get-current-user';

export default async function MecanicienLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const user = await getCurrentUser();

  if (!user) {
    redirect('/connexion');
  }

  if (user.profile.app_role !== 'mechanic') {
    redirect('/');
  }

  return (
    <div className="flex min-h-screen flex-col bg-muted/30">
      <header className="border-b bg-background">
        <div className="container flex h-14 items-center justify-between">
          <div className="flex items-center gap-2">
            <Link href="/mon-planning" className="font-semibold">
              Mon atelier
            </Link>
            <span className="rounded-md bg-success/10 px-2 py-0.5 text-xs font-medium text-success">
              Mécanicien
            </span>
          </div>
          <div className="flex items-center gap-4 text-sm">
            <span className="text-muted-foreground">{user.profile.full_name ?? user.email}</span>
            <LogoutButton />
          </div>
        </div>
      </header>

      <main className="container flex-1 py-6">{children}</main>
    </div>
  );
}
