import Link from 'next/link';

export default function NotFound() {
  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <div className="max-w-md text-center">
        <p className="mb-2 text-sm font-medium text-muted-foreground">Erreur 404</p>
        <h1 className="mb-2 text-2xl font-semibold">Page introuvable</h1>
        <p className="mb-6 text-muted-foreground">
          La page que vous cherchez n’existe pas ou a été déplacée.
        </p>
        <Link
          href="/"
          className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:opacity-90"
        >
          Retour à l’accueil
        </Link>
      </div>
    </main>
  );
}
