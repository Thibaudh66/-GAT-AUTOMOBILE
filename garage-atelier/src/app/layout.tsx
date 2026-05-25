import Link from 'next/link';

import { Logo } from '@/components/layout/Logo';

export default function PublicLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const garagePhone = process.env.NEXT_PUBLIC_GARAGE_PHONE ?? '';
  const garageEmail = process.env.NEXT_PUBLIC_GARAGE_EMAIL ?? '';

  return (
    <div className="flex min-h-screen flex-col">
      {/* Header */}
      <header className="sticky top-0 z-50 border-b border-border/60 bg-background/80 backdrop-blur-md">
        <div className="container flex h-20 items-center justify-between">
          <Link href="/" className="group transition-opacity hover:opacity-80">
            <Logo variant="full" />
          </Link>

          <nav className="flex items-center gap-2 sm:gap-6">
            <Link
              href="/prendre-rendez-vous"
              className="hidden sm:inline-flex text-sm font-medium text-foreground/70 hover:text-foreground transition-colors"
            >
              Prendre rendez-vous
            </Link>
            <Link
              href="/connexion"
              className="btn-primary text-sm"
            >
              Mon espace
            </Link>
          </nav>
        </div>
      </header>

      <main className="flex-1">{children}</main>

      {/* Footer chaleureux */}
      <footer className="mt-20 border-t border-border bg-card">
        <div className="container py-12">
          <div className="grid gap-8 sm:grid-cols-3">
            <div>
              <Logo variant="full" className="mb-4" />
              <p className="text-sm text-muted-foreground leading-relaxed">
                L&apos;expertise et le savoir-faire d&apos;un atelier de proximité, au service de votre véhicule depuis toujours.
              </p>
            </div>

            <div>
              <h3 className="font-serif text-lg mb-3">Contact</h3>
              <ul className="space-y-1 text-sm text-muted-foreground">
                {garagePhone && (
                  <li>
                    <a href={`tel:${garagePhone}`} className="hover:text-foreground transition-colors">
                      {garagePhone}
                    </a>
                  </li>
                )}
                {garageEmail && (
                  <li>
                    <a href={`mailto:${garageEmail}`} className="hover:text-foreground transition-colors">
                      {garageEmail}
                    </a>
                  </li>
                )}
              </ul>
            </div>

            <div>
              <h3 className="font-serif text-lg mb-3">Horaires</h3>
              <ul className="space-y-1 text-sm text-muted-foreground">
                <li>Lundi — Vendredi</li>
                <li>8h00 — 17h30</li>
                <li className="pt-2 text-foreground/60 italic">Fermé le samedi</li>
              </ul>
            </div>
          </div>

          <div className="mt-12 pt-6 border-t border-border flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-muted-foreground">
            <p>© {new Date().getFullYear()} Égat Automobile — Tous droits réservés</p>
            <Link href="/mentions-legales" className="hover:text-foreground transition-colors">
              Mentions légales
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
