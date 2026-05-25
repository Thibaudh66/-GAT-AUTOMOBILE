import { createBrowserClient } from '@supabase/ssr';

import type { Database } from '@/types/database.types';

/**
 * Client Supabase à utiliser dans les Client Components (use client).
 *
 * Pour Server Components, route handlers et Server Actions :
 *   utiliser createServerClient depuis @/lib/supabase/server
 */
export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  );
}
