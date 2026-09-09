import { db } from './database.js';

export async function clearDemoDataIfPresent() {
  try {
    const demoFazendaIds = ['faz-1'];
    const demoUserIds = ['usr-1', 'usr-2', 'usr-3'];
    const demoAnimalIds = ['ani-1', 'ani-2', 'ani-3', 'ani-4', 'ani-5', 'ani-6'];

    for (const id of demoFazendaIds) {
      const existiaFake = await db.fazendas.get(id);
      if (existiaFake) {
        await db.fazendas.delete(id);
        await db.animais.where('fazenda_id').equals(id).delete();
        await db.lotes.where('fazenda_id').equals(id).delete();
        await db.piquetes.where('fazenda_id').equals(id).delete();

        // Enfileira o delete pra apagar na nuvem também, caso tenha sido enviado antes
        await db.sync_queue.add({
          id: `sync-${Date.now()}-cleanup-${id}`,
          entidade: 'fazendas',
          entidade_id: id,
          acao: 'delete',
          status: 'pending',
          created_at: new Date().toISOString()
        });
      }
    }

    for (const uId of demoUserIds) {
      const existiaUser = await db.usuarios.get(uId);
      if (existiaUser) {
        await db.usuarios.delete(uId);
        await db.sync_queue.add({
          id: `sync-${Date.now()}-cleanup-usr-${uId}`,
          entidade: 'usuarios',
          entidade_id: uId,
          acao: 'delete',
          status: 'pending',
          created_at: new Date().toISOString()
        });
      }
    }

    for (const aId of demoAnimalIds) {
      const existiaAnimal = await db.animais.get(aId);
      if (existiaAnimal) {
        await db.animais.delete(aId);
        await db.sync_queue.add({
          id: `sync-${Date.now()}-cleanup-ani-${aId}`,
          entidade: 'animais',
          entidade_id: aId,
          acao: 'delete',
          status: 'pending',
          created_at: new Date().toISOString()
        });
      }
    }
  } catch (err) {
    console.warn('[Clear Demo Data Warning]:', err.message);
  }
}
