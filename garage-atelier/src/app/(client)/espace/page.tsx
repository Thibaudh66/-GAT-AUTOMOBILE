export const metadata = {
  title: 'Mon espace',
};

export default function EspaceClientPage() {
  return (
    <div>
      <h1 className="text-2xl font-semibold">Mon espace personnel</h1>
      <p className="mt-2 text-muted-foreground">
        Vos rendez-vous et le suivi de vos véhicules apparaîtront ici.
      </p>
    </div>
  );
}
