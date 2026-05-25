import { LoginForm } from './login-form';

export const metadata = {
  title: 'Connexion',
};

export default function ConnexionPage({
  searchParams,
}: {
  searchParams: { next?: string };
}) {
  return (
    <div className="w-full max-w-sm">
      <div className="mb-6 text-center">
        <h1 className="text-2xl font-semibold">Connexion</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Accédez à votre espace personnel
        </p>
      </div>

      <LoginForm next={searchParams.next} />
    </div>
  );
}
