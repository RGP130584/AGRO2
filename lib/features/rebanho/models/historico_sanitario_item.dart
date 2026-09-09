import '../../../data/local/database.dart';

/// Modelo de dados para um item no histórico sanitário.
/// Combina a aplicação com os dados do produto.
class HistoricoSanitarioItem {
  final AplicacaoSanitaria aplicacao;
  final Produto produto;

  HistoricoSanitarioItem({
    required this.aplicacao,
    required this.produto,
  });
}