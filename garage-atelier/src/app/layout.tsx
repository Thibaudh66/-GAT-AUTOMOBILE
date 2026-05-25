import Link from 'next/link';

import { Logo } from '@/components/layout/Logo';

export default function PublicLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const garagePhone = process.env.NEXT_PUBLIC_GARAGE_PHONE ?? '';
  const garageEmail = process.env.NEXT_PUBLIC_GARAGE_EMAIL ?? '';

  return (
    <div className="flex min-h-screen flex-col">
      <header className="sticky top-0 z-50 border-b border-border/60 bg-background/80 backdrop-blur-md">
        <div className="container flex h-20 items-center justify-between">
          <Link href="/" className="transition-opacity hover:opacity-80">
            <Logo variant="full" />
          </Link>

          <nav className="flex items-center gap-6">
            <Link
              href="/prendre-rendez-vous"
              className="hidden text-sm font-medium text-foreground/70 transition-colors hover:text-foreground sm:inline-flex"
            >
              Prendre rendez-vous
            </Link>
            <Link href="/connexion" className="btn-primary text-sm">
              Mon espace
            </Link>
          </nav>
        </div>
      </header>

      <main className="flex-1">{children}</main>

      <footer className="mt-20 border-t border-border bg-card">
        <div className="container py-12">
          <div className="grid gap-8 sm:grid-cols-3">
            <div>
              <div className="mb-4">
                <Logo variant="full" />
              </div>
              <p className="text-sm leading-relaxed text-muted-foreground">
                L&apos;expertise et le savoir-faire d&apos;un atelier de proximité, au service de
                votre véhicule.
              </p>
            </div>

            <div>
              <h3 className="mb-3 font-serif text-lg">Contact</h3>
              <ul className="space-y-1 text-sm text-muted-foreground">
                {garagePhone ? (
                  <li>
                    <a
                      href={`tel:${garagePhone}`}
                      className="transition-colors hover:text-foreground"
                    >
                      {garagePhone}
                    </a>
                  </li>
                ) : null}
                {garageEmail ? (
                  <li>
                    <a
                      href={`mailto:${garageEmail}`}
                      className="transition-colors hover:text-foreground"
                    >
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
                <li className="pt-2 italic text-foreground/60">Fermé le samedi</li>
              </ul>
            </div>
          </div>

          <div className="mt-12 flex flex-col items-center justify-between gap-3 border-t border-border pt-6 text-xs text-muted-foreground sm:flex-row">
            <p>© {new Date().getFullYear()} Égat Automobile — Tous droits réservés</p>
            <Link href="/mentions-legales" className="transition-colors hover:text-foreground">
              Mentions légales
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
