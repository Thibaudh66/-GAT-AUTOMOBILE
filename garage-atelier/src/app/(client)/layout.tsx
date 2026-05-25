import Link from 'next/link';
import { redirect } from 'next/navigation';

import { LogoutButton } from '@/components/layout/logout-button';
import { getCurrentUser } from '@/lib/auth/get-current-user';

export default async function ClientLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const user = await getCurrentUser();

  if (!user) {
    redirect('/connexion');
  }

  if (user.profile.app_role !== 'client') {
    redirect('/');
  }

  return (
    <div className="flex min-h-screen flex-col">
      <header className="border-b">
        <div className="container flex h-14 items-center justify-between">
          <Link href="/espace" className="font-semibold">
            Mon espace
          </Link>
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
