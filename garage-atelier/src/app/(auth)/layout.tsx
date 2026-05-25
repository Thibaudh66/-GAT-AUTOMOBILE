import Link from 'next/link';

export default function AuthLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const garageName = process.env.NEXT_PUBLIC_GARAGE_NAME ?? 'Garage Atelier';

  return (
    <div className="flex min-h-screen flex-col">
      <header className="border-b">
        <div className="container flex h-16 items-center">
          <Link href="/" className="text-lg font-semibold">
            {garageName}
          </Link>
        </div>
      </header>

      <main className="flex flex-1 items-center justify-center p-6">{children}</main>
    </div>
  );
}
