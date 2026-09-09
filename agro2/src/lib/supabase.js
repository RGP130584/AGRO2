import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://yykhelzfnoespjvzjqnb.supabase.co';
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY || 'sb_publishable_6vY3s1kWRc0BR-RezIFSNQ_jmZhO20Z';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
