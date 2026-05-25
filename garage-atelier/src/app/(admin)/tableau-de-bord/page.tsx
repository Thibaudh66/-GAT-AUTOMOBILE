export const metadata = {
  title: 'Tableau de bord',
};

export default function TableauDeBordPage() {
  return (
    <div>
      <h1 className="text-2xl font-semibold">Tableau de bord</h1>
      <p className="mt-2 text-muted-foreground">
        Les KPI seront affichés ici à partir du Sprint S9.
      </p>

      <div className="mt-8 rounded-lg border border-dashed bg-background p-8 text-center">
        <p className="text-sm text-muted-foreground">
          Page en construction — les indicateurs apparaîtront ici
        </p>
      </div>
    </div>
  );
}
