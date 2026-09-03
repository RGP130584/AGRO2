import '../../../data/local/database.dart';

/// A data class to hold the combined information for the animal list.
///
/// This model joins data from the `Animal`, `Lote`, and `AplicacaoSanitaria`
/// tables to provide a complete overview for each item in the list.
class AnimalListItem {
  final Animal animal;
  final Lote lote;
  final bool emCarencia;
  final DateTime? carenciaFim;

  AnimalListItem({
    required this.animal,
    required this.lote,
    required this.emCarencia,
    this.carenciaFim,
  });
}