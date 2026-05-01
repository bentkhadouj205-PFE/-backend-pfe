import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = "https://uvmruxcjpgovdrwvykyn.supabase.co";
const SUPABASE_KEY = "sb_secret_XHeSzkwCgKvxp6TCZ6IS5Q_GLDX9Vga";

export const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);