/**
 * Cálculo de Ganho Médio Diário (GMD) e métricas de peso bovino
 */

export function calcularGMD(pesoAtual, pesoAnterior, dataAtualStr, dataAnteriorStr) {
  if (!pesoAnterior || pesoAnterior <= 0 || !dataAnteriorStr) {
    return { gmd: 0, diasDecorridos: 0, ganhoTotalKg: 0 };
  }

  const d1 = new Date(dataAnteriorStr);
  const d2 = new Date(dataAtualStr);
  const diffTime = d2.getTime() - d1.getTime();
  const diasDecorridos = Math.max(1, Math.round(diffTime / (1000 * 60 * 60 * 24)));

  const ganhoTotalKg = Number((pesoAtual - pesoAnterior).toFixed(2));
  const gmd = Number((ganhoTotalKg / diasDecorridos).toFixed(3));

  return {
    gmd,
    diasDecorridos,
    ganhoTotalKg
  };
}

export function kgParaArroba(pesoKg, rendimentoCarcacaPercentual = 50) {
  // 1 Arroba viva comercial = 30kg vivo (considerando 50% de rendimento de carcaça = 15kg de carne limpa)
  if (!pesoKg) return 0;
  return Number((pesoKg / 30).toFixed(1));
}
