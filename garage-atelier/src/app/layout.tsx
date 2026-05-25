import Link from 'next/link';

export default function PublicLayout(props: { children: React.ReactNode }) {
  const garagePhone = process.env.NEXT_PUBLIC_GARAGE_PHONE || '';
  const garageEmail = process.env.NEXT_PUBLIC_GARAGE_EMAIL || '';

  return (
    <div className="flex min-h-screen flex-col">
      <header className="sticky top-0 z-50 border-b border-border bg-background">
        <div className="container flex h-20 items-center justify-between">
          <Link href="/" className="flex items-center gap-3">
            <span
              className="flex h-10 w-10 items-center justify-center rounded-full text-lg font-medium italic"
              style={{ backgroundColor: 'hsl(14 65% 42%)', color: 'hsl(36 33% 97%)' }}
            >
              E
            </span>
            <span className="flex flex-col leading-tight">
              <span className="font-serif text-xl">Egat</span>
              <span className="text-xs uppercase tracking-widest text-muted-foreground">
                Automobile
              </span>
            </span>
          </Link>

          <nav className="flex items-center gap-6">
            <Link
              href="/prendre-rendez-vous"
              className="hidden text-sm font-medium text-foreground hover:opacity-70 sm:inline-flex"
            >
              Prendre rendez-vous
            </Link>
            <Link href="/connexion" className="btn-primary text-sm">
              Mon espace
            </Link>
          </nav>
        </div>
      </header>

      <main className="flex-1">{props.children}</main>

      <footer className="mt-20 border-t border-border bg-card">
        <div className="container py-12">
          <div className="grid gap-8 sm:grid-cols-3">
            <div>
              <h3 className="mb-3 font-serif text-lg">Egat Automobile</h3>
              <p className="text-sm text-muted-foreground">
                Atelier mecanique au coeur de la Cerdagne.
              </p>
            </div>

            <div>
              <h3 className="mb-3 font-serif text-lg">Contact</h3>
              <ul className="space-y-1 text-sm text-muted-foreground">
                <li>Egat (66120) - Cerdagne</li>
                {garagePhone ? <li>{garagePhone}</li> : null}
                {garageEmail ? <li>{garageEmail}</li> : null}
              </ul>
            </div>

            <div>
              <h3 className="mb-3 font-serif text-lg">Horaires</h3>
              <ul className="space-y-1 text-sm text-muted-foreground">
                <li>Lundi - Vendredi</li>
                <li>8h00 - 17h30</li>
                <li className="pt-2 italic">Ferme le samedi</li>
              </ul>
            </div>
          </div>

          <div className="mt-12 border-t border-border pt-6 text-xs text-muted-foreground">
            <p>Egat Automobile - Tous droits reserves</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
