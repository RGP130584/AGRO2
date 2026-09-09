import { db, requestPersistentStorage } from './database.js';

export async function seedDatabaseIfEmpty() {
  await requestPersistentStorage();
  
  const userCount = await db.usuarios.count();
  if (userCount > 0) return; // Já possui dados

  console.log('[Seed] Inicializando base de demonstração Agro 2...');

  const now = new Date();
  const hojeStr = now.toISOString().split('T')[0];

  // 1. Usuários
  const usuarios = [
    {
      id: 'usr-1',
      nome: 'Ricardo Gerente Geral',
      email: 'admin@agro.com',
      senha: '123',
      perfil: 'proprietario',
      telefone: '(62) 98765-4321',
      crmv: '',
      ativo: true,
      created_at: new Date().toISOString()
    },
    {
      id: 'usr-2',
      nome: 'Dr. Marcos Veterinário',
      email: 'vet@agro.com',
      senha: '123',
      perfil: 'veterinario',
      telefone: '(62) 99123-4567',
      crmv: 'CRMV-GO 9842',
      ativo: true,
      created_at: new Date().toISOString()
    },
    {
      id: 'usr-3',
      nome: 'João Vaqueiro / Capataz',
      email: 'vaqueiro@agro.com',
      senha: '123',
      perfil: 'colaborador',
      telefone: '(62) 99888-7766',
      crmv: '',
      ativo: true,
      created_at: new Date().toISOString()
    }
  ];
  await db.usuarios.bulkAdd(usuarios);

  // 2. Fazenda
  const fazendaId = 'faz-1';
  await db.fazendas.add({
    id: fazendaId,
    nome: 'Fazenda Santa Fé & Pecuária',
    proprietario_nome: 'Ricardo Agropecuária S.A.',
    localizacao: 'Rio Verde - GO',
    area_ha: 1450,
    sync_status: 'synced',
    created_at: new Date().toISOString()
  });

  // 3. Piquetes
  const piquetes = [
    { id: 'piq-1', fazenda_id: fazendaId, nome: 'Piquete 01 — Capim Mombaça', area_ha: 45, tipo_pastagem: 'Mombaça', capacidade_cabecas: 80, sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'piq-2', fazenda_id: fazendaId, nome: 'Piquete 02 — Braquiarão Rotacionado', area_ha: 60, tipo_pastagem: 'Brachiaria Brizantha', capacidade_cabecas: 110, sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'piq-3', fazenda_id: fazendaId, nome: 'Piquete 03 — Piatã Maternidade', area_ha: 35, tipo_pastagem: 'Piatã', capacidade_cabecas: 50, sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'piq-4', fazenda_id: fazendaId, nome: 'Confinamento — Curral Linha A', area_ha: 12, tipo_pastagem: 'Confinamento Intensivo', capacidade_cabecas: 150, sync_status: 'synced', created_at: new Date().toISOString() }
  ];
  await db.piquetes.bulkAdd(piquetes);

  // 4. Lotes
  const lotes = [
    { id: 'lot-1', fazenda_id: fazendaId, piquete_id: 'piq-4', nome: 'Lote 01 — Nelore Terminação Confinamento', categoria: 'Boi Gordo', finalidade: 'Engorda Intensiva', sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'lot-2', fazenda_id: fazendaId, piquete_id: 'piq-1', nome: 'Lote 02 — Cruzamento Angus / Garrotes', categoria: 'Garrote', finalidade: 'Recria a Pasto', sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'lot-3', fazenda_id: fazendaId, piquete_id: 'piq-3', nome: 'Lote 03 — Matrizes Nelore P.O. & Cria', categoria: 'Vaca', finalidade: 'Reprodução e IATF', sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'lot-4', fazenda_id: fazendaId, piquete_id: 'piq-2', nome: 'Lote 04 — Bezerros Desmama Precoce', categoria: 'Bezerro', finalidade: 'Desmama e Adaptação', sync_status: 'synced', created_at: new Date().toISOString() }
  ];
  await db.lotes.bulkAdd(lotes);

  // 5. Produtos (Farmácia e Nutrição)
  const produtos = [
    { id: 'prod-1', nome: 'Vacina Aftosa & Clostridiose Polivalente', tipo: 'vacina', carencia_dias: 0, unidade: 'Dose (ml)', saldo_atual: 450, estoque_minimo: 100, validade: '2027-12-31', preco_custo: 3.50, sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'prod-2', nome: 'Ivermectina 3.15% Longa Ação', tipo: 'medicamento', carencia_dias: 35, unidade: 'Frasco 500ml', saldo_atual: 18, estoque_minimo: 5, validade: '2026-11-20', preco_custo: 185.00, sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'prod-3', nome: 'Antibiótico Oxitetraciclina L.A.', tipo: 'medicamento', carencia_dias: 28, unidade: 'Frasco 100ml', saldo_atual: 12, estoque_minimo: 4, validade: '2026-10-15', preco_custo: 92.00, sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'prod-4', nome: 'Ração Terminação Confinamento 18% PB', tipo: 'racao', carencia_dias: 0, unidade: 'Saco 40kg', saldo_atual: 320, estoque_minimo: 50, validade: '2027-06-30', preco_custo: 68.00, sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'prod-5', nome: 'Sal Mineral Fosfatado 80', tipo: 'suplemento', carencia_dias: 0, unidade: 'Saco 30kg', saldo_atual: 85, estoque_minimo: 20, validade: '2027-08-15', preco_custo: 54.00, sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'prod-6', nome: 'Anti-inflamatório Flunixin Meglumine', tipo: 'medicamento', carencia_dias: 7, unidade: 'Frasco 50ml', saldo_atual: 8, estoque_minimo: 3, validade: '2026-09-30', preco_custo: 78.00, sync_status: 'synced', created_at: new Date().toISOString() }
  ];
  await db.produtos.bulkAdd(produtos);

  // 6. Animais
  // Calculando data de carência ativa para o boi 1002 (para demonstrar selo vermelho)
  const carenciaFutura = new Date();
  carenciaFutura.setDate(carenciaFutura.getDate() + 18);
  const carenciaFimStr = carenciaFutura.toISOString().split('T')[0];

  const animais = [
    {
      id: 'ani-1',
      fazenda_id: fazendaId,
      lote_id: 'lot-1',
      brinco: 'BR-1001',
      rfid: '982000412389101',
      raca: 'Nelore Mocho',
      categoria: 'Boi Gordo',
      sexo: 'Macho',
      data_nascimento: '2024-03-10',
      peso_atual: 535,
      data_ultima_pesagem: hojeStr,
      gmd_recente: 1.55,
      carencia_fim: null,
      status: 'ativo',
      sync_status: 'synced',
      created_at: new Date().toISOString()
    },
    {
      id: 'ani-2',
      fazenda_id: fazendaId,
      lote_id: 'lot-1',
      brinco: 'BR-1002',
      rfid: '982000412389102',
      raca: 'Nelore',
      categoria: 'Boi Gordo',
      sexo: 'Macho',
      data_nascimento: '2024-03-15',
      peso_atual: 512,
      data_ultima_pesagem: hojeStr,
      gmd_recente: 1.42,
      carencia_fim: carenciaFimStr, // CARÊNCIA ATIVA!
      status: 'ativo',
      sync_status: 'synced',
      created_at: new Date().toISOString()
    },
    {
      id: 'ani-3',
      fazenda_id: fazendaId,
      lote_id: 'lot-1',
      brinco: 'BR-1003',
      rfid: '982000412389103',
      raca: 'Nelore',
      categoria: 'Boi Gordo',
      sexo: 'Macho',
      data_nascimento: '2024-04-01',
      peso_atual: 528,
      data_ultima_pesagem: hojeStr,
      gmd_recente: 1.60,
      carencia_fim: null,
      status: 'ativo',
      sync_status: 'synced',
      created_at: new Date().toISOString()
    },
    {
      id: 'ani-4',
      fazenda_id: fazendaId,
      lote_id: 'lot-2',
      brinco: 'BR-2001',
      rfid: '982000412389201',
      raca: 'Cruzamento Angus/Nelore',
      categoria: 'Garrote',
      sexo: 'Macho',
      data_nascimento: '2025-01-10',
      peso_atual: 360,
      data_ultima_pesagem: hojeStr,
      gmd_recente: 0.95,
      carencia_fim: null,
      status: 'ativo',
      sync_status: 'synced',
      created_at: new Date().toISOString()
    },
    {
      id: 'ani-5',
      fazenda_id: fazendaId,
      lote_id: 'lot-2',
      brinco: 'BR-2002',
      rfid: '982000412389202',
      raca: 'Cruzamento Angus/Nelore',
      categoria: 'Garrote',
      sexo: 'Macho',
      data_nascimento: '2025-01-18',
      peso_atual: 348,
      data_ultima_pesagem: hojeStr,
      gmd_recente: 0.91,
      carencia_fim: null,
      status: 'ativo',
      sync_status: 'synced',
      created_at: new Date().toISOString()
    },
    {
      id: 'ani-6',
      fazenda_id: fazendaId,
      lote_id: 'lot-3',
      brinco: 'MAT-3001',
      rfid: '982000412389301',
      raca: 'Nelore P.O.',
      categoria: 'Vaca',
      sexo: 'Fêmea',
      data_nascimento: '2022-09-05',
      peso_atual: 490,
      data_ultima_pesagem: hojeStr,
      gmd_recente: 0.25,
      carencia_fim: null,
      status: 'ativo',
      sync_status: 'synced',
      created_at: new Date().toISOString()
    }
  ];
  await db.animais.bulkAdd(animais);

  // 7. Aplicação Sanitária ativa para demonstração
  const aplicacaoPassada = new Date();
  aplicacaoPassada.setDate(aplicacaoPassada.getDate() - 17);
  await db.aplicacoes_sanitarias.add({
    id: 'apl-1',
    animal_id: 'ani-2',
    lote_id: 'lot-1',
    fazenda_id: fazendaId,
    produto_id: 'prod-2',
    produto_nome: 'Ivermectina 3.15% Longa Ação',
    data_aplicacao: aplicacaoPassada.toISOString().split('T')[0],
    carencia_fim: carenciaFimStr,
    dose: '10 ml',
    via: 'Subcutânea',
    motivo: 'Controle de endo e ectoparasitas na entrada do confinamento',
    responsavel: 'Dr. Marcos Veterinário',
    sync_status: 'synced',
    created_at: new Date().toISOString()
  });

  // 8. Dieta Confinamento
  await db.dietas.add({
    id: 'diet-1',
    fazenda_id: fazendaId,
    lote_id: 'lot-1',
    categoria: 'Boi Gordo',
    nome: 'Dieta Acabamento Confinamento 18% PB',
    descricao: 'Concentrado + Silagem de Milho (60/40)',
    consumo_cabeca_dia_kg: 9.5,
    produto_id: 'prod-4',
    ativa: true,
    sync_status: 'synced',
    created_at: new Date().toISOString()
  });

  // 9. Pesagens de Histórico (para demonstrar gráfico de GMD)
  const data30DiasAtras = new Date();
  data30DiasAtras.setDate(data30DiasAtras.getDate() - 30);
  const data30Str = data30DiasAtras.toISOString().split('T')[0];

  await db.pesagens.bulkAdd([
    { id: 'pes-1', animal_id: 'ani-1', lote_id: 'lot-1', fazenda_id: fazendaId, data: data30Str, peso: 488, peso_anterior: 0, dias_decorridos: 0, gmd: 0, responsavel: 'João Vaqueiro', sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'pes-2', animal_id: 'ani-1', lote_id: 'lot-1', fazenda_id: fazendaId, data: hojeStr, peso: 535, peso_anterior: 488, dias_decorridos: 30, gmd: 1.56, responsavel: 'João Vaqueiro', sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'pes-3', animal_id: 'ani-2', lote_id: 'lot-1', fazenda_id: fazendaId, data: data30Str, peso: 469, peso_anterior: 0, dias_decorridos: 0, gmd: 0, responsavel: 'João Vaqueiro', sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'pes-4', animal_id: 'ani-2', lote_id: 'lot-1', fazenda_id: fazendaId, data: hojeStr, peso: 512, peso_anterior: 469, dias_decorridos: 30, gmd: 1.43, responsavel: 'João Vaqueiro', sync_status: 'synced', created_at: new Date().toISOString() }
  ]);

  // 10. Lançamentos Financeiros
  await db.financeiro_lancamentos.bulkAdd([
    { id: 'fin-1', fazenda_id: fazendaId, tipo: 'pagar', categoria: 'Insumos / Ração', descricao: 'Compra de 320 sacos de ração confinamento 18%', valor: 21760.00, vencimento: hojeStr, data_pagamento: hojeStr, status: 'pago', fornecedor_cliente: 'Nutrição Animal Agro S/A', sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'fin-2', fazenda_id: fazendaId, tipo: 'pagar', categoria: 'Veterinária', descricao: 'Honorários assistência veterinária e IATF', valor: 4500.00, vencimento: '2026-09-25', data_pagamento: null, status: 'pendente', fornecedor_cliente: 'Dr. Marcos Veterinária ME', sync_status: 'synced', created_at: new Date().toISOString() },
    { id: 'fin-3', fazenda_id: fazendaId, tipo: 'receber', categoria: 'Venda de Gado', descricao: 'Venda de 45 novilhos precoces frigorífico', valor: 168750.00, vencimento: '2026-09-30', data_pagamento: null, status: 'pendente', fornecedor_cliente: 'Frigorífico Minerva / JBS', sync_status: 'synced', created_at: new Date().toISOString() }
  ]);

  console.log('[Seed] Base de dados populada com sucesso.');
}
