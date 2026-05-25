import { createBrowserClient } from '@supabase/ssr';
import type { Database } from '@/types/database.types';

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

console.log('[SUPABASE_CHECK] URL defined:', !!SUPABASE_URL, '| KEY defined:', !!SUPABASE_ANON_KEY);

if (!SUPABASE_URL) {
  throw new Error('NEXT_PUBLIC_SUPABASE_URL est manquante au build');
}
if (!SUPABASE_ANON_KEY) {
  throw new Error('NEXT_PUBLIC_SUPABASE_ANON_KEY est manquante au build');
}

export function createClient() {
  return createBrowserClient<Database>(SUPABASE_URL, SUPABASE_ANON_KEY);
}
