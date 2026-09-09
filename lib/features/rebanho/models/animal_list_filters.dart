/// Classe para encapsular os parâmetros de filtro da lista de animais.
class AnimalListFilters {
  final String? loteId;
  final bool? emCarencia;
  final String? brincoQuery;

  const AnimalListFilters({
    this.loteId,
    this.emCarencia,
    this.brincoQuery,
  });

  // É uma boa prática implementar igualdade para parâmetros de providers .family.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalListFilters &&
          runtimeType == other.runtimeType &&
          loteId == other.loteId &&
          emCarencia == other.emCarencia &&
          brincoQuery == other.brincoQuery;

  @override
  int get hashCode => loteId.hashCode ^ emCarencia.hashCode ^ brincoQuery.hashCode;
}