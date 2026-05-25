import Link from 'next/link';

export default function HomePage() {
  const garageName = process.env.NEXT_PUBLIC_GARAGE_NAME ?? 'Garage Atelier';

  return (
    <div className="container py-16 sm:py-24">
      <div className="mx-auto max-w-2xl text-center">
        <h1 className="text-balance text-4xl font-semibold tracking-tight sm:text-5xl">
          Bienvenue chez {garageName}
        </h1>
        <p className="mt-6 text-balance text-lg text-muted-foreground">
          Prenez rendez-vous en ligne pour l’entretien ou la réparation de votre véhicule.
          Suivez l’avancement de votre intervention en temps réel.
        </p>
        <div className="mt-10 flex flex-wrap items-center justify-center gap-4">
          <Link
            href="/prendre-rendez-vous"
            className="rounded-md bg-primary px-6 py-3 text-base font-medium text-primary-foreground hover:opacity-90"
          >
            Prendre rendez-vous
          </Link>
          <Link
            href="/connexion"
            className="rounded-md border border-input px-6 py-3 text-base font-medium hover:bg-accent"
          >
            Accéder à mon espace
          </Link>
        </div>
      </div>
    </div>
  );
}
