import Link from 'next/link';

export default function HomePage() {
  const garagePhone = process.env.NEXT_PUBLIC_GARAGE_PHONE ?? '';

  return (
    <>
      {/* HERO */}
      <section className="relative overflow-hidden">
        {/* Décoration de fond : cercles flous terracotta très subtils */}
        <div
          className="pointer-events-none absolute -top-40 -right-40 h-96 w-96 rounded-full opacity-20 blur-3xl"
          style={{ background: 'hsl(14 65% 42%)' }}
          aria-hidden="true"
        />
        <div
          className="pointer-events-none absolute top-60 -left-40 h-80 w-80 rounded-full opacity-10 blur-3xl"
          style={{ background: 'hsl(156 22% 22%)' }}
          aria-hidden="true"
        />

        <div className="container relative section-padding">
          <div className="mx-auto max-w-3xl text-center">
            <p className="text-accent-serif text-primary mb-4 text-lg">
              Atelier mécanique automobile
            </p>
            <h1 className="text-5xl sm:text-6xl lg:text-7xl font-medium leading-[1.05] mb-6">
              Égat,
              <br />
              <span className="text-accent-serif text-primary">l&apos;exigence du détail.</span>
            </h1>
            <p className="text-lg sm:text-xl text-muted-foreground max-w-2xl mx-auto leading-relaxed mb-10">
              Diagnostic, entretien et réparation toutes marques. Prenez rendez-vous en ligne et suivez l&apos;avancement de votre véhicule en temps réel.
            </p>
            <div className="flex flex-wrap items-center justify-center gap-3">
              <Link href="/prendre-rendez-vous" className="btn-primary">
                Prendre rendez-vous
              </Link>
              <Link href="/connexion" className="btn-secondary">
                Accéder à mon espace
              </Link>
            </div>

            {garagePhone && (
              <p className="mt-12 text-sm text-muted-foreground">
                Une urgence ?
                <a href={`tel:${garagePhone}`} className="ml-2 font-medium text-foreground hover:text-primary transition-colors">
                  Appelez-nous au {garagePhone}
                </a>
              </p>
            )}
          </div>
        </div>
      </section>

      {/* VALEURS / SERVICES */}
      <section className="border-t border-border bg-card">
        <div className="container section-padding">
          <div className="mx-auto max-w-2xl text-center mb-16">
            <p className="text-accent-serif text-primary mb-3">Nos services</p>
            <h2 className="text-3xl sm:text-4xl font-medium leading-tight">
              Un atelier complet, des engagements clairs
            </h2>
          </div>

          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            <article className="card-artisan">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                <svg className="h-6 w-6 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="1.5">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M11.42 15.17 17.25 21A2.652 2.652 0 0 0 21 17.25l-5.877-5.877M11.42 15.17l2.496-3.03c.317-.384.74-.626 1.208-.766M11.42 15.17l-4.655 5.653a2.548 2.548 0 1 1-3.586-3.586l6.837-5.63m5.108-.233c.55-.164 1.163-.188 1.743-.14a4.5 4.5 0 0 0 4.486-6.336l-3.276 3.277a3.004 3.004 0 0 1-2.25-2.25l3.276-3.276a4.5 4.5 0 0 0-6.336 4.486c.091 1.076-.071 2.264-.904 2.95l-.102.085m-1.745 1.437L5.909 7.5H4.5L2.25 3.75l1.5-1.5L7.5 4.5v1.409l4.26 4.26m-1.745 1.437 1.745-1.437m6.615 8.206L15.75 15.75M4.867 19.125h.008v.008h-.008v-.008Z" />
                </svg>
              </div>
              <h3 className="font-serif text-xl mb-2">Mécanique générale</h3>
              <p className="text-sm text-muted-foreground leading-relaxed">
                Vidange, freinage, distribution, embrayage. L&apos;entretien complet de votre véhicule, toutes marques confondues.
              </p>
            </article>

            <article className="card-artisan">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                <svg className="h-6 w-6 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="1.5">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 6.042A8.967 8.967 0 0 0 6 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 0 1 6 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 0 1 6-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0 0 18 18a8.967 8.967 0 0 0-6 2.292m0-14.25v14.25" />
                </svg>
              </div>
              <h3 className="font-serif text-xl mb-2">Diagnostic électronique</h3>
              <p className="text-sm text-muted-foreground leading-relaxed">
                Lecture des défauts via valise OBD, identification précise des pannes et préconisations claires.
              </p>
            </article>

            <article className="card-artisan">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                <svg className="h-6 w-6 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="1.5">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                </svg>
              </div>
              <h3 className="font-serif text-xl mb-2">Préparation au CT</h3>
              <p className="text-sm text-muted-foreground leading-relaxed">
                Contrôle préventif avant passage au contrôle technique pour identifier et corriger les points à surveiller.
              </p>
            </article>

            <article className="card-artisan">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                <svg className="h-6 w-6 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="1.5">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M15.59 14.37a6 6 0 0 1-5.84 7.38v-4.8m5.84-2.58a14.98 14.98 0 0 0 6.16-12.12A14.98 14.98 0 0 0 9.631 8.41m5.96 5.96a14.926 14.926 0 0 1-5.841 2.58m-.119-8.54a6 6 0 0 0-7.381 5.84h4.8m2.581-5.84a14.927 14.927 0 0 0-2.58 5.84m2.699 2.7c-.103.021-.207.041-.311.06a15.09 15.09 0 0 1-2.448-2.448 14.9 14.9 0 0 1 .06-.312m-2.24 2.39a4.493 4.493 0 0 0-1.757 4.306 4.493 4.493 0 0 0 4.306-1.758M16.5 9a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0Z" />
                </svg>
              </div>
              <h3 className="font-serif text-xl mb-2">Climatisation</h3>
              <p className="text-sm text-muted-foreground leading-relaxed">
                Recharge en gaz, vérification du circuit, désinfection du système. Pour rouler au frais toute l&apos;année.
              </p>
            </article>

            <article className="card-artisan">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                <svg className="h-6 w-6 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="1.5">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                  <path strokeLinecap="round" strokeLinejoin="round" d="M15.91 11.672a.375.375 0 0 1 0 .656l-5.603 3.113a.375.375 0 0 1-.557-.328V8.887c0-.286.307-.466.557-.327l5.603 3.112Z" />
                </svg>
              </div>
              <h3 className="font-serif text-xl mb-2">Pneumatiques</h3>
              <p className="text-sm text-muted-foreground leading-relaxed">
                Montage, équilibrage, parallélisme. Toutes les marques en stock ou en commande sous 24 heures.
              </p>
            </article>

            <article className="card-artisan">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                <svg className="h-6 w-6 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="1.5">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                </svg>
              </div>
              <h3 className="font-serif text-xl mb-2">Suivi en temps réel</h3>
              <p className="text-sm text-muted-foreground leading-relaxed">
                Recevez des notifications à chaque étape : prise en charge, diagnostic, fin d&apos;intervention. Plus besoin d&apos;appeler.
              </p>
            </article>
          </div>
        </div>
      </section>

      {/* COMMENT ÇA MARCHE */}
      <section className="border-t border-border">
        <div className="container section-padding">
          <div className="mx-auto max-w-2xl text-center mb-16">
            <p className="text-accent-serif text-primary mb-3">En quelques clics</p>
            <h2 className="text-3xl sm:text-4xl font-medium leading-tight">
              Simple comme bonjour
            </h2>
          </div>

          <div className="grid gap-12 md:grid-cols-3 max-w-4xl mx-auto">
            <div className="text-center">
              <div className="mx-auto mb-5 flex h-14 w-14 items-center justify-center rounded-full bg-primary text-primary-foreground font-serif text-2xl">
                1
              </div>
              <h3 className="font-serif text-xl mb-2">Choisissez votre intervention</h3>
              <p className="text-sm text-muted-foreground leading-relaxed">
                Vidange, freinage, diagnostic… sélectionnez ce dont votre véhicule a besoin.
              </p>
            </div>

            <div className="text-center">
              <div className="mx-auto mb-5 flex h-14 w-14 items-center justify-center rounded-full bg-primary text-primary-foreground font-serif text-2xl">
                2
              </div>
              <h3 className="font-serif text-xl mb-2">Réservez un créneau</h3>
              <p className="text-sm text-muted-foreground leading-relaxed">
                Visualisez les disponibilités et choisissez le moment qui vous convient le mieux.
              </p>
            </div>

            <div className="text-center">
              <div className="mx-auto mb-5 flex h-14 w-14 items-center justify-center rounded-full bg-primary text-primary-foreground font-serif text-2xl">
                3
              </div>
              <h3 className="font-serif text-xl mb-2">Suivez l&apos;avancement</h3>
              <p className="text-sm text-muted-foreground leading-relaxed">
                Recevez des notifications à chaque étape jusqu&apos;à la restitution de votre véhicule.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA FINAL */}
      <section className="border-t border-border bg-secondary text-secondary-foreground">
        <div className="container section-padding text-center">
          <div className="mx-auto max-w-2xl">
            <h2 className="font-serif text-3xl sm:text-4xl font-medium mb-4">
              Prêt à confier votre véhicule ?
            </h2>
            <p className="text-secondary-foreground/80 text-lg mb-8 leading-relaxed">
              Prenez rendez-vous en moins de deux minutes. Une demande de validation suit, et c&apos;est tout.
            </p>
            <Link
              href="/prendre-rendez-vous"
              className="inline-flex items-center justify-center gap-2 rounded-md bg-primary px-8 py-4 text-base font-medium text-primary-foreground transition-all hover:bg-primary/90 hover:shadow-lg"
            >
              Prendre rendez-vous
              <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
                <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3" />
              </svg>
            </Link>
          </div>
        </div>
      </section>
    </>
  );
}
