import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://yykhelzfnoespjvzjqnb.supabase.co';
const SUPABASE_KEY = 'sb_publishable_6vY3s1kWRc0BR-RezIFSNQ_jmZhO20Z';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function checkAll() {
  console.log('=== ANIMAIS NO SUPABASE ===');
  const { data: animais, error: aErr } = await supabase.from('animais').select('*');
  console.log('Animais error:', aErr);
  console.log('Animais data:', JSON.stringify(animais, null, 2));

  console.log('=== FAZENDAS NO SUPABASE ===');
  const { data: fazendas } = await supabase.from('fazendas').select('*');
  console.log('Fazendas data:', JSON.stringify(fazendas, null, 2));

  console.log('=== USUARIOS NO SUPABASE ===');
  const { data: usuarios } = await supabase.from('usuarios').select('*');
  console.log('Usuarios data:', JSON.stringify(usuarios, null, 2));
}

checkAll();
