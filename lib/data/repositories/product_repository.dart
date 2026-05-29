import '../models/product.dart';
import '../services/database_service.dart';

class ProductRepository {
  final _db = DatabaseService.instance;

  Future<List<Product>> getAll({int? categoryId, bool? isAvailable}) async {
    String sql = 'SELECT * FROM products WHERE 1=1';
    final params = <String, dynamic>{};

    if (categoryId != null) {
      sql += ' AND category_id = @categoryId';
      params['categoryId'] = categoryId;
    }
    if (isAvailable != null) {
      sql += ' AND is_available = @isAvailable';
      params['isAvailable'] = isAvailable;
    }
    sql += ' ORDER BY name';

    final rows = await _db.query(sql, params: params.isEmpty ? null : params);
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> getById(int id) async {
    final row = await _db.queryOne(
      'SELECT * FROM products WHERE id = @id',
      params: {'id': id},
    );
    return row != null ? Product.fromMap(row) : null;
  }

  Future<List<Product>> search(String query) async {
    final rows = await _db.query(
      'SELECT * FROM products WHERE name ILIKE @query ORDER BY name',
      params: {'query': '%$query%'},
    );
    return rows.map(Product.fromMap).toList();
  }

  Future<Product> create({
    required String name,
    String? description,
    required double price,
    int? categoryId,
    String? imageUrl,
  }) async {
    final row = await _db.queryOne(
      '''INSERT INTO products (name, description, price, category_id, image_url)
         VALUES (@name, @description, @price, @categoryId, @imageUrl)
         RETURNING *''',
      params: {
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'imageUrl': imageUrl,
      },
    );
    return Product.fromMap(row!);
  }

  Future<bool> update(Product product) async {
    final affected = await _db.execute(
      '''UPDATE products
         SET name = @name, description = @description, price = @price,
             category_id = @categoryId, image_url = @imageUrl,
             is_available = @isAvailable, updated_at = CURRENT_TIMESTAMP
         WHERE id = @id''',
      params: {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'categoryId': product.categoryId,
        'imageUrl': product.imageUrl,
        'isAvailable': product.isAvailable,
      },
    );
    return affected > 0;
  }

  Future<bool> toggleAvailability(int id, bool isAvailable) async {
    final affected = await _db.execute(
      'UPDATE products SET is_available = @v, updated_at = CURRENT_TIMESTAMP WHERE id = @id',
      params: {'id': id, 'v': isAvailable},
    );
    return affected > 0;
  }

  Future<bool> delete(int id) async {
    final affected = await _db.execute(
      'DELETE FROM products WHERE id = @id',
      params: {'id': id},
    );
    return affected > 0;
  }
}
