import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/order.dart';
import '../data/models/order_item.dart';
import '../data/models/product.dart';
import '../data/repositories/order_repository.dart';
import '../core/config/app_config.dart';

class CartEntry {
  final Product product;
  int quantity;
  String? notes;

  CartEntry({required this.product, this.quantity = 1, this.notes});

  double get subtotal => product.price * quantity;
}

class PosProvider extends ChangeNotifier {
  final _orderRepo = OrderRepository();
  final _uuid = const Uuid();

  final List<CartEntry> _cart = [];
  String? _customerName;
  String? _tableNumber;
  String? _orderNotes;
  bool _isLoading = false;
  String? _error;
  Order? _lastOrder;

  List<CartEntry> get cart => List.unmodifiable(_cart);
  String? get customerName => _customerName;
  String? get tableNumber => _tableNumber;
  String? get orderNotes => _orderNotes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Order? get lastOrder => _lastOrder;
  bool get isEmpty => _cart.isEmpty;

  int get itemCount => _cart.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal => _cart.fold(0, (sum, e) => sum + e.subtotal);

  double get taxAmount => subtotal * AppConfig.taxRate;

  double get total => subtotal + taxAmount;

  void addToCart(Product product) {
    final index = _cart.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      _cart[index].quantity++;
    } else {
      _cart.add(CartEntry(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cart.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }

  void increaseQty(int productId) {
    final idx = _cart.indexWhere((e) => e.product.id == productId);
    if (idx >= 0) {
      _cart[idx].quantity++;
      notifyListeners();
    }
  }

  void decreaseQty(int productId) {
    final idx = _cart.indexWhere((e) => e.product.id == productId);
    if (idx >= 0) {
      if (_cart[idx].quantity <= 1) {
        _cart.removeAt(idx);
      } else {
        _cart[idx].quantity--;
      }
      notifyListeners();
    }
  }

  void setItemNotes(int productId, String? notes) {
    final idx = _cart.indexWhere((e) => e.product.id == productId);
    if (idx >= 0) {
      _cart[idx].notes = notes;
      notifyListeners();
    }
  }

  void setCustomerInfo({String? name, String? table, String? notes}) {
    _customerName = name;
    _tableNumber = table;
    _orderNotes = notes;
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _customerName = null;
    _tableNumber = null;
    _orderNotes = null;
    _lastOrder = null;
    _error = null;
    notifyListeners();
  }

  Future<Order?> checkout({
    required PaymentMethod paymentMethod,
    required double paymentAmount,
  }) async {
    if (_cart.isEmpty) return null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orderNumber = _generateOrderNumber();
      final items = _cart
          .map((e) => OrderItem(
                productId: e.product.id,
                productName: e.product.name,
                quantity: e.quantity,
                unitPrice: e.product.price,
                subtotal: e.subtotal,
                notes: e.notes,
              ))
          .toList();

      final createdOrder = await _orderRepo.createOrder(
        orderNumber: orderNumber,
        items: items,
        totalAmount: total,
        taxAmount: taxAmount,
        paymentMethod: paymentMethod,
        paymentAmount: paymentAmount,
        changeAmount: paymentAmount - total,
        customerName: _customerName,
        tableNumber: _tableNumber,
        notes: _orderNotes,
      );

      _cart.clear();
      _customerName = null;
      _tableNumber = null;
      _orderNotes = null;
      _lastOrder = createdOrder;
      _error = null;
      notifyListeners();
      return createdOrder;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    final prefix =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final suffix = _uuid.v4().substring(0, 4).toUpperCase();
    return '#$prefix-$suffix';
  }
}
