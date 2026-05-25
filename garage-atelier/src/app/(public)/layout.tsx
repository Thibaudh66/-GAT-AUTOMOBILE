import Link from 'next/link';

function LogoFull() {
  return (
    <div className="inline-flex items-center gap-3">
      <svg
        width="40"
        height="40"
        viewBox="0 0 64 64"
        xmlns="http://www.w3.org/2000/svg"
        aria-label="Logo Egat Automobile"
        role="img"
      >
        <circle cx="32" cy="32" r="30" fill="hsl(14 65% 42%)" />
        <circle
          cx="32"
          cy="32"
          r="28"
          fill="none"
          stroke="hsl(36 33% 97%)"
          strokeWidth="0.5"
          opacity="0.3"
        />
        <text
          x="32"
          y="42"
          textAnchor="middle"
          fill="hsl(36 33% 97%)"
          fontFamily="Georgia, serif"
          fontSize="34"
          fontWeight="500"
          fontStyle="italic"
        >
          {'\u00C9'}
        </text>
        <line
          x1="22"
          y1="50"
          x2="42"
          y2="50"
          stroke="hsl(36 33% 97%)"
          strokeWidth="1.2"
          strokeLinecap="round"
        />
      </svg>
      <div className="flex flex-col leading-tight">
        <span className="font-serif text-xl tracking-tight">{'\u00C9'}gat</span>
        <span className="text-[0.65rem] uppercase tracking-[0.2em] text-muted-foreground">
          Automobile
        </span>
      </div>
    </div>
  );
}

export default function PublicLayout(props: { children: React.ReactNode }) {
  const garagePhone = process.env.NEXT_PUBLIC_GARAGE_PHONE || '';
  const garageEmail = process.env.NEXT_PUBLIC_GARAGE_EMAIL || '';

  return (
    <div className="flex min-h-screen flex-col">
      <header className="sticky top-0 z-50 border-b border-border bg-background/95 backdrop-blur">
        <div className="container flex h-20 items-center justify-between">
          <Link href="/" className="transition-opacity hover:opacity-80">
            <LogoFull />
          </Link>

          <nav className="flex items-center gap-6">
            <Link
              href="/prendre-rendez-vous"
              className="hidden text-sm font-medium text-foreground/70 hover:text-foreground sm:inline-flex"
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
              <div className="mb-4">
                <LogoFull />
              </div>
              <p className="text-sm leading-relaxed text-muted-foreground">
                Votre atelier m{'\u00E9'}canique au c{'\u0153'}ur de la Cerdagne. Entretien,
                r{'\u00E9'}paration et pr{'\u00E9'}paration hivernale.
              </p>
            </div>

            <div>
              <h3 className="mb-3 font-serif text-lg">Contact</h3>
              <ul className="space-y-1 text-sm text-muted-foreground">
                <li>{'\u00C9'}gat (66120) — Cerdagne</li>
                {garagePhone ? (
                  <li>
                    <a href={`tel:${garagePhone}`} className="hover:text-foreground">
                      {garagePhone}
                    </a>
                  </li>
                ) : null}
                {garageEmail ? (
                  <li>
                    <a href={`mailto:${garageEmail}`} className="hover:text-foreground">
                      {garageEmail}
                    </a>
                  </li>
                ) : null}
              </ul>
            </div>

            <div>
              <h3 className="mb-3 font-serif text-lg">Horaires</h3>
              <ul className="space-y-1 text-sm text-muted-foreground">
                <li>Lundi — Vendredi</li>
                <li>8h00 — 17h30</li>
                <li className="pt-2 italic text-foreground/60">Ferm{'\u00E9'} le samedi</li>
              </ul>
            </div>
          </div>

          <div className="mt-12 flex flex-col items-center justify-between gap-3 border-t border-border pt-6 text-xs text-muted-foreground sm:flex-row">
            <p>
              © {new Date().getFullYear()} {'\u00C9'}gat Automobile — Tous droits r
              {'\u00E9'}serv{'\u00E9'}s
            </p>
            <Link href="/mentions-legales" className="hover:text-foreground">
              Mentions l{'\u00E9'}gales
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
