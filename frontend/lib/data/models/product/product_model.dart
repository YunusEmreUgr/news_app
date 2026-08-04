import '../../../domain/entities/product_entity.dart';

class ProductModel {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String description;
  final int categoryId;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    required this.categoryId,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: json['name']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : (double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0),
      stock: json['stock'] is int
          ? json['stock']
          : (int.tryParse(json['stock']?.toString() ?? '0') ?? 0),
      description: json['description']?.toString() ?? '',
      categoryId: json['categoryId'] is int
          ? json['categoryId']
          : (int.tryParse(json['categoryId']?.toString() ?? '1') ?? 1),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        'description': description,
        'categoryId': categoryId,
        'createdAt': createdAt?.toIso8601String(),
      };

  ProductEntity toEntity() => ProductEntity(
        id: id,
        name: name,
        price: price,
        stock: stock,
        description: description,
        categoryId: categoryId,
        createdAt: createdAt,
      );
}
