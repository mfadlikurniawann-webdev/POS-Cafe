import 'package:flutter/foundation.dart';
import '../data/models/order.dart';
import '../data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final _repo = OrderRepository();

  List<Order> _orders = [];
  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _weeklySales = [];
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _monthlySales = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  List<Map<String, dynamic>> get weeklySales => _weeklySales;
  List<Map<String, dynamic>> get topProducts => _topProducts;
  List<Map<String, dynamic>> get monthlySales => _monthlySales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get todayRevenue {
    final v = _dashboardStats['today_revenue'];
    return v != null ? double.parse(v.toString()) : 0;
  }

  int get todayOrders {
    final v = _dashboardStats['today_orders'];
    return v != null ? int.parse(v.toString()) : 0;
  }

  double get avgOrder {
    final v = _dashboardStats['avg_order'];
    return v != null ? double.parse(v.toString()) : 0;
  }

  double get totalRevenue {
    final v = _dashboardStats['total_revenue'];
    return v != null ? double.parse(v.toString()) : 0;
  }

  Future<void> loadOrders({OrderStatus? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repo.getRecent(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.getDashboardStats(),
        _repo.getWeeklySales(),
        _repo.getTopProducts(),
        _repo.getMonthlySales(),
      ]);
      _dashboardStats = results[0] as Map<String, dynamic>;
      _weeklySales = results[1] as List<Map<String, dynamic>>;
      _topProducts = results[2] as List<Map<String, dynamic>>;
      _monthlySales = results[3] as List<Map<String, dynamic>>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(int id) async {
    try {
      final ok = await _repo.cancelOrder(id);
      if (ok) {
        final idx = _orders.indexWhere((o) => o.id == id);
        if (idx >= 0) {
          _orders.removeAt(idx);
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
}
