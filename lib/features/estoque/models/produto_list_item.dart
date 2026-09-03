import '../../../data/local/database.dart';

/// Modelo de dados para a lista de produtos, combinando o produto e seu saldo.
class ProdutoListItem {
  final Produto produto;
  final double saldo;

  ProdutoListItem({
    required this.produto,
    required this.saldo,
  });
}