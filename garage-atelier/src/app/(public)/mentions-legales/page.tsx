export const metadata = {
  title: 'Mentions légales',
};

export default function MentionsLegalesPage() {
  return (
    <div className="container py-16">
      <div className="mx-auto max-w-2xl space-y-8">
        <header>
          <p className="text-accent-serif text-primary mb-2">Informations légales</p>
          <h1 className="font-serif text-4xl font-medium">Mentions légales</h1>
        </header>

        <section>
          <h2 className="font-serif text-xl mb-2">Éditeur du site</h2>
          <p className="text-muted-foreground leading-relaxed">
            Ce site est édité par Égat Automobile. Les coordonnées complètes (raison sociale, SIRET, adresse, gérant) seront ajoutées prochainement.
          </p>
        </section>

        <section>
          <h2 className="font-serif text-xl mb-2">Hébergement</h2>
          <p className="text-muted-foreground leading-relaxed">
            Ce site est hébergé par Netlify Inc. (États-Unis). Les données personnelles sont stockées chez Supabase, sur des serveurs situés au sein de l&apos;Union européenne.
          </p>
        </section>

        <section>
          <h2 className="font-serif text-xl mb-2">Données personnelles</h2>
          <p className="text-muted-foreground leading-relaxed">
            Conformément au Règlement Général sur la Protection des Données (RGPD), vous disposez d&apos;un droit d&apos;accès, de rectification et de suppression de vos données personnelles. Pour exercer ce droit, contactez-nous via les coordonnées indiquées en pied de page.
          </p>
        </section>

        <section>
          <h2 className="font-serif text-xl mb-2">Cookies</h2>
          <p className="text-muted-foreground leading-relaxed">
            Ce site utilise uniquement des cookies techniques nécessaires à son bon fonctionnement (session d&apos;authentification). Aucun cookie publicitaire ou de suivi tiers n&apos;est déposé sans votre consentement.
          </p>
        </section>
      </div>
    </div>
  );
}
