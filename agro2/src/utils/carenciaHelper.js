/**
 * Utilitários para gestão de carência sanitária (medicamentos e vacinas)
 */

export function calcularFimCarencia(dataAplicacaoStr, diasCarencia) {
  if (!diasCarencia || diasCarencia <= 0) return null;
  const data = new Date(dataAplicacaoStr);
  data.setDate(data.getDate() + parseInt(diasCarencia, 10));
  return data.toISOString().split('T')[0];
}

export function statusCarencia(carenciaFimStr) {
  if (!carenciaFimStr) {
    return { emCarencia: false, diasRestantes: 0, statusText: 'Liberado para Abate/Leite' };
  }
  
  const hoje = new Date();
  hoje.setHours(0, 0, 0, 0);
  
  const fim = new Date(carenciaFimStr);
  fim.setHours(0, 0, 0, 0);
  
  const diffTime = fim.getTime() - hoje.getTime();
  const diasRestantes = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  
  if (diasRestantes >= 0) {
    return {
      emCarencia: true,
      diasRestantes: diasRestantes === 0 ? 1 : diasRestantes,
      dataFim: carenciaFimStr,
      statusText: `Em Carência (${diasRestantes === 0 ? 'Último dia' : `${diasRestantes} dias restantes`})`
    };
  }
  
  return {
    emCarencia: false,
    diasRestantes: 0,
    dataFim: carenciaFimStr,
    statusText: 'Carência Concluída (Liberado)'
  };
}
