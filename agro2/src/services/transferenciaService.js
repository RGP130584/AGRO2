import { db } from '../db/database.js';

/**
 * Ponto de Extensão do Domínio: Transferência de Rebanho entre Fazendas.
 * 
 * Regra de Negócio (Seção 13):
 * Registra a transferência formal preservando rastreabilidade:
 * - Fazenda Origem
 * - Fazenda Destino
 * - Animal / Lista de Animais
 * - Lote de Origem (opcional)
 * - Lote de Destino (opcional)
 * - Data
 * - Responsável
 * - Motivo / Observação
 */
export async function transferirAnimalFazenda({
  animalId,
  fazendaOrigemId,
  fazendaDestinoId,
  loteOrigemId = null,
  loteDestinoId = null,
  data = new Date().toISOString().split('T')[0],
  responsavel = 'Operador',
  motivo = 'Transferência de Rebanho entre Fazendas',
  observacao = ''
}) {
  if (!animalId || !fazendaOrigemId || !fazendaDestinoId) {
    throw new Error('Animais, Fazenda de Origem e Fazenda de Destino são obrigatórios para transferência.');
  }

  if (fazendaOrigemId === fazendaDestinoId) {
    throw new Error('A fazenda de destino deve ser diferente da fazenda de origem.');
  }

  const animal = await db.animais.get(animalId);
  if (!animal) {
    throw new Error(`Animal com ID ${animalId} não encontrado.`);
  }

  const fazOrigem = await db.fazendas.get(fazendaOrigemId);
  const fazDestino = await db.fazendas.get(fazendaDestinoId);

  console.log(`[HERD TRANSFER PREPARATION] Transferindo animal ${animal.brinco} (${animal.id}) da fazenda ${fazOrigem?.nome || fazendaOrigemId} para ${fazDestino?.nome || fazendaDestinoId}`);

  // Retorna evento estruturado de transferência pronto para persistência rastreável
  const transferenciaLog = {
    id: `transf-${Date.now()}-${Math.random().toString(36).substr(2, 6)}`,
    animal_id: animalId,
    brinco: animal.brinco,
    fazenda_origem_id: fazendaOrigemId,
    fazenda_destino_id: fazendaDestinoId,
    lote_origem_id: loteOrigemId || animal.lote_id,
    lote_destino_id: loteDestinoId || null,
    data,
    responsavel,
    motivo,
    observacao,
    created_at: new Date().toISOString()
  };

  return transferenciaLog;
}
