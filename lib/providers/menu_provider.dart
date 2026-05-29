import 'package:flutter/foundation.dart' hide Category;
import '../data/models/category.dart';
import '../data/models/product.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/product_repository.dart';

class MenuProvider extends ChangeNotifier {
  final _categoryRepo = CategoryRepository();
  final _productRepo = ProductRepository();

  List<Category> _categories = [];
  List<Product> _products = [];
  Category _selectedCategory = categoryAll;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  Category get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> get filteredProducts {
    var list = _products;

    if (_selectedCategory.id != 0) {
      list = list.where((p) => p.categoryId == _selectedCategory.id).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _categoryRepo.getAll(),
        _productRepo.getAll(),
      ]);
      _categories = results[0] as List<Category>;
      _products = results[1] as List<Product>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    try {
      _products = await _productRepo.getAll();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void selectCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> addProduct({
    required String name,
    String? description,
    required double price,
    int? categoryId,
  }) async {
    try {
      await _productRepo.create(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
      );
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final ok = await _productRepo.update(product);
      if (ok) await loadProducts();
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleAvailability(int id, bool isAvailable) async {
    try {
      final ok = await _productRepo.toggleAvailability(id, isAvailable);
      if (ok) {
        final idx = _products.indexWhere((p) => p.id == id);
        if (idx >= 0) {
          _products[idx] = _products[idx].copyWith(isAvailable: isAvailable);
          notifyListeners();
        }
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final ok = await _productRepo.delete(id);
      if (ok) {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Category? getCategoryById(int? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
