export function formatarMoeda(valor) {
  if (valor === null || valor === undefined || isNaN(valor)) return 'R$ 0,00';
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(valor);
}

export function formatarData(dataStr) {
  if (!dataStr) return '-';
  try {
    const [ano, mes, dia] = dataStr.split('T')[0].split('-');
    if (!ano || !mes || !dia) return dataStr;
    return `${dia}/${mes}/${ano}`;
  } catch (e) {
    return dataStr;
  }
}

export function formatarNumero(valor, casas = 1) {
  if (valor === null || valor === undefined || isNaN(valor)) return '0';
  return Number(valor).toLocaleString('pt-BR', {
    minimumFractionDigits: casas,
    maximumFractionDigits: casas
  });
}
