interface LogoProps {
  /** Taille du logo en pixels (par défaut 40) */
  size?: number;
  /** Variante : monogramme seul ou avec wordmark à côté */
  variant?: 'mark' | 'full';
  /** Classe CSS additionnelle */
  className?: string;
}

/**
 * Logo Égat Automobile
 *
 * - variant="mark"  → uniquement le monogramme É (carré)
 * - variant="full"  → monogramme + texte "Égat Automobile" à côté
 *
 * Utilise les couleurs du thème (terracotta + ivoire) via les classes Tailwind
 * pour s'adapter automatiquement au dark mode si activé un jour.
 */
export function Logo({ size = 40, variant = 'mark', className = '' }: LogoProps) {
  return (
    <div className={`inline-flex items-center gap-3 ${className}`}>
      <svg
        width={size}
        height={size}
        viewBox="0 0 64 64"
        xmlns="http://www.w3.org/2000/svg"
        aria-label="Logo Égat Automobile"
        role="img"
      >
        {/* Cercle de fond — terracotta */}
        <circle cx="32" cy="32" r="30" fill="hsl(14 65% 42%)" />

        {/* Cercle intérieur subtil pour la profondeur */}
        <circle
          cx="32"
          cy="32"
          r="28"
          fill="none"
          stroke="hsl(36 33% 97%)"
          strokeWidth="0.5"
          opacity="0.3"
        />

        {/* Lettre É — serif, élégante */}
        <text
          x="32"
          y="42"
          textAnchor="middle"
          fill="hsl(36 33% 97%)"
          fontFamily="Fraunces, Georgia, serif"
          fontSize="34"
          fontWeight="500"
          fontStyle="italic"
        >
          É
        </text>

        {/* Trait horizontal sous le monogramme — la "route" artisan */}
        <line
          x1="22"
          y1="50"
          x2="42"
          y2="50"
          stroke="hsl(36 33% 97%)"
          strokeWidth="1.2"
          strokeLinecap="round"
        />
      </svg>

      {variant === 'full' && (
        <div className="flex flex-col leading-tight">
          <span className="font-serif text-xl tracking-tight">Égat</span>
          <span className="text-[0.65rem] uppercase tracking-[0.2em] text-muted-foreground">
            Automobile
          </span>
        </div>
      )}
    </div>
  );
}
