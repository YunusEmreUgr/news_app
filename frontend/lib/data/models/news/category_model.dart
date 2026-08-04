class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? json['Id'] ?? 0,
      name: json['name'] ?? json['Name'] ?? '',
      slug: json['slug'] ?? json['Slug'] ?? '',
      icon: json['icon'] ?? json['Icon'],
      description: json['description'] ?? json['Description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'description': description,
    };
  }
}
