class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int? categoryId;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.categoryId,
    this.imageUrl,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as int,
        name: map['name'] as String,
        description: map['description'] as String?,
        price: double.parse(map['price'].toString()),
        categoryId: map['category_id'] as int?,
        imageUrl: map['image_url'] as String?,
        isAvailable: map['is_available'] as bool? ?? true,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'].toString())
            : null,
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'].toString())
            : null,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'image_url': imageUrl,
        'is_available': isAvailable,
      };

  Product copyWith({
    String? name,
    String? description,
    double? price,
    int? categoryId,
    String? imageUrl,
    bool? isAvailable,
  }) =>
      Product(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        categoryId: categoryId ?? this.categoryId,
        imageUrl: imageUrl ?? this.imageUrl,
        isAvailable: isAvailable ?? this.isAvailable,
      );
}
