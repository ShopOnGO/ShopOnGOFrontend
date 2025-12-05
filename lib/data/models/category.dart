class Category {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int? parentCategoryID;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.parentCategoryID,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Без категории',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      parentCategoryID: json['parentCategoryID'],
    );
  }
}