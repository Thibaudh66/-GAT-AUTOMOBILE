'use client';

export function LogoutButton() {
  async function handleLogout() {
    await fetch('/api/auth/logout', { method: 'POST' });
    window.location.href = '/';
  }

  return (
    <button
      type="button"
      onClick={handleLogout}
      className="text-sm text-muted-foreground hover:text-foreground"
    >
      Se déconnecter
    </button>
  );
}
