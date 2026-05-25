export default function MentionsLegalesPage() {
  const garageName = process.env.NEXT_PUBLIC_GARAGE_NAME ?? 'Garage Atelier';

  return (
    <div className="container py-16">
      <div className="mx-auto max-w-2xl space-y-6">
        <h1 className="text-3xl font-semibold">Mentions légales</h1>

        <section>
          <h2 className="mb-2 text-xl font-medium">Éditeur du site</h2>
          <p className="text-muted-foreground">
            {garageName} — à compléter avec l’adresse, le SIRET et les coordonnées du gérant.
          </p>
        </section>

        <section>
          <h2 className="mb-2 text-xl font-medium">Hébergement</h2>
          <p className="text-muted-foreground">
            Ce site est hébergé par Netlify Inc. (États-Unis). Les données personnelles sont
            stockées chez Supabase (Union Européenne).
          </p>
        </section>

        <section>
          <h2 className="mb-2 text-xl font-medium">Données personnelles</h2>
          <p className="text-muted-foreground">
            Conformément au RGPD, vous disposez d’un droit d’accès, de rectification et de
            suppression de vos données personnelles. Pour exercer ce droit, contactez-nous.
          </p>
        </section>
      </div>
    </div>
  );
}
