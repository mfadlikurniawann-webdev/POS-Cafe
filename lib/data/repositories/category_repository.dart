import '../models/category.dart';
import '../services/database_service.dart';

class CategoryRepository {
  final _db = DatabaseService.instance;

  Future<List<Category>> getAll() async {
    final rows = await _db.query(
      'SELECT * FROM categories WHERE is_active = true ORDER BY sort_order, name',
    );
    return rows.map(Category.fromMap).toList();
  }

  Future<Category?> getById(int id) async {
    final row = await _db.queryOne(
      'SELECT * FROM categories WHERE id = @id',
      params: {'id': id},
    );
    return row != null ? Category.fromMap(row) : null;
  }

  Future<Category> create(String name, String icon, String color) async {
    final row = await _db.queryOne(
      '''INSERT INTO categories (name, icon, color)
         VALUES (@name, @icon, @color)
         RETURNING *''',
      params: {'name': name, 'icon': icon, 'color': color},
    );
    return Category.fromMap(row!);
  }

  Future<bool> update(int id, String name, String icon, String color) async {
    final affected = await _db.execute(
      '''UPDATE categories
         SET name = @name, icon = @icon, color = @color
         WHERE id = @id''',
      params: {'id': id, 'name': name, 'icon': icon, 'color': color},
    );
    return affected > 0;
  }

  Future<bool> delete(int id) async {
    final affected = await _db.execute(
      'UPDATE categories SET is_active = false WHERE id = @id',
      params: {'id': id},
    );
    return affected > 0;
  }
}
