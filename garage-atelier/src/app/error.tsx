'use client';

import { useEffect } from 'react';

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // À remplacer par Sentry en Sprint S9
    console.error('Erreur globale :', error);
  }, [error]);

  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <div className="max-w-md text-center">
        <h1 className="mb-2 text-2xl font-semibold">Une erreur est survenue</h1>
        <p className="mb-6 text-muted-foreground">
          Désolé, quelque chose s’est mal passé. Vous pouvez réessayer ou revenir à l’accueil.
        </p>
        <div className="flex justify-center gap-3">
          <button
            type="button"
            onClick={reset}
            className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:opacity-90"
          >
            Réessayer
          </button>
          <a
            href="/"
            className="rounded-md border border-input px-4 py-2 text-sm font-medium hover:bg-accent"
          >
            Retour à l’accueil
          </a>
        </div>
      </div>
    </main>
  );
}
