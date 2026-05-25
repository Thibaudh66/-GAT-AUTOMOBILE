import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Combine et déduplique des classes Tailwind.
 *
 * Usage :
 *   cn('bg-red-500', condition && 'bg-blue-500')
 *   → 'bg-blue-500' si condition vraie (twMerge gère le conflit)
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
