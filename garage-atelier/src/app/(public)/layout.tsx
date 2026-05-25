import Link from 'next/link';

export default function PublicLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const garageName = process.env.NEXT_PUBLIC_GARAGE_NAME ?? 'Garage Atelier';

  return (
    <div className="flex min-h-screen flex-col">
      <header className="border-b">
        <div className="container flex h-16 items-center justify-between">
          <Link href="/" className="text-lg font-semibold">
            {garageName}
          </Link>
          <nav className="flex items-center gap-6 text-sm">
            <Link href="/prendre-rendez-vous" className="hover:underline">
              Prendre rendez-vous
            </Link>
            <Link
              href="/connexion"
              className="rounded-md bg-primary px-4 py-2 font-medium text-primary-foreground hover:opacity-90"
            >
              Se connecter
            </Link>
          </nav>
        </div>
      </header>

      <main className="flex-1">{children}</main>

      <footer className="border-t py-6">
        <div className="container flex flex-col items-center justify-between gap-2 text-sm text-muted-foreground sm:flex-row">
          <p>
            © {new Date().getFullYear()} {garageName}
          </p>
          <Link href="/mentions-legales" className="hover:underline">
            Mentions légales
          </Link>
        </div>
      </footer>
    </div>
  );
}
