class ProductEntity {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String description;
  final int categoryId;
  final DateTime? createdAt;

  ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    required this.categoryId,
    this.createdAt,
  });
}
