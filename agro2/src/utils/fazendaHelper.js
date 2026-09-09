import { db } from '../db/database.js';

export async function getActiveFazendaId() {
  try {
    const first = await db.fazendas.toCollection().first();
    return first ? first.id : 'faz-1';
  } catch (err) {
    return 'faz-1';
  }
}
