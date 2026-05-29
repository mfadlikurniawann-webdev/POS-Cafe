class Category {
  final int id;
  final String name;
  final String icon;
  final String color;
  final int sortOrder;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    this.icon = 'coffee',
    this.color = '#4A2C17',
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as int,
        name: map['name'] as String,
        icon: map['icon'] as String? ?? 'coffee',
        color: map['color'] as String? ?? '#4A2C17',
        sortOrder: map['sort_order'] as int? ?? 0,
        isActive: map['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'icon': icon,
        'color': color,
        'sort_order': sortOrder,
        'is_active': isActive,
      };

  Category copyWith({
    String? name,
    String? icon,
    String? color,
    int? sortOrder,
    bool? isActive,
  }) =>
      Category(
        id: id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        sortOrder: sortOrder ?? this.sortOrder,
        isActive: isActive ?? this.isActive,
      );
}

// Virtual "All" category for filter
const Category categoryAll = Category(id: 0, name: 'Semua', icon: 'all');
