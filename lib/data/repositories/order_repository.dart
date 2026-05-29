import '../models/order.dart';
import '../models/order_item.dart';
import '../services/database_service.dart';

class OrderRepository {
  final _db = DatabaseService.instance;

  Future<List<Order>> getRecent({int limit = 50, OrderStatus? status}) async {
    String sql = 'SELECT * FROM orders WHERE 1=1';
    final params = <String, dynamic>{};

    if (status != null) {
      sql += ' AND status = @status';
      params['status'] = status.value;
    }
    sql += ' ORDER BY created_at DESC LIMIT @limit';
    params['limit'] = limit;

    final rows = await _db.query(sql, params: params);
    final orders = rows.map((r) => Order.fromMap(r)).toList();

    // Load items for each order
    final result = <Order>[];
    for (final order in orders) {
      final items = await getItemsByOrderId(order.id!);
      result.add(Order.fromMap(rows[orders.indexOf(order)], items: items));
    }
    return result;
  }

  Future<List<OrderItem>> getItemsByOrderId(int orderId) async {
    final rows = await _db.query(
      'SELECT * FROM order_items WHERE order_id = @orderId ORDER BY id',
      params: {'orderId': orderId},
    );
    return rows.map(OrderItem.fromMap).toList();
  }

  Future<Order?> getById(int id) async {
    final row = await _db.queryOne(
      'SELECT * FROM orders WHERE id = @id',
      params: {'id': id},
    );
    if (row == null) return null;
    final items = await getItemsByOrderId(id);
    return Order.fromMap(row, items: items);
  }

  Future<Order> createOrder({
    required String orderNumber,
    required List<OrderItem> items,
    required double totalAmount,
    required double taxAmount,
    required PaymentMethod paymentMethod,
    required double paymentAmount,
    required double changeAmount,
    String? customerName,
    String? tableNumber,
    String? notes,
    double discountAmount = 0,
  }) async {
    final orderRow = await _db.queryOne(
      '''INSERT INTO orders (
           order_number, status, total_amount, tax_amount, discount_amount,
           payment_method, payment_amount, change_amount,
           customer_name, table_number, notes, completed_at
         ) VALUES (
           @orderNumber, 'completed', @totalAmount, @taxAmount, @discountAmount,
           @paymentMethod, @paymentAmount, @changeAmount,
           @customerName, @tableNumber, @notes, CURRENT_TIMESTAMP
         ) RETURNING *''',
      params: {
        'orderNumber': orderNumber,
        'totalAmount': totalAmount,
        'taxAmount': taxAmount,
        'discountAmount': discountAmount,
        'paymentMethod': paymentMethod.value,
        'paymentAmount': paymentAmount,
        'changeAmount': changeAmount,
        'customerName': customerName,
        'tableNumber': tableNumber,
        'notes': notes,
      },
    );

    final orderId = orderRow!['id'] as int;

    for (final item in items) {
      await _db.execute(
        '''INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal, notes)
           VALUES (@orderId, @productId, @productName, @quantity, @unitPrice, @subtotal, @notes)''',
        params: {
          'orderId': orderId,
          'productId': item.productId,
          'productName': item.productName,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'subtotal': item.subtotal,
          'notes': item.notes,
        },
      );
    }

    return getById(orderId).then((o) => o!);
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final stats = await _db.queryOne(
      '''SELECT
           COUNT(*) FILTER (WHERE DATE(created_at) = @today) as today_orders,
           COALESCE(SUM(total_amount) FILTER (WHERE DATE(created_at) = @today), 0) as today_revenue,
           COALESCE(AVG(total_amount) FILTER (WHERE DATE(created_at) = @today), 0) as avg_order,
           COUNT(*) as total_orders,
           COALESCE(SUM(total_amount), 0) as total_revenue
         FROM orders WHERE status = 'completed' ''',
      params: {'today': todayStr},
    );

    return stats ?? {};
  }

  Future<List<Map<String, dynamic>>> getWeeklySales() async {
    final rows = await _db.query(
      '''SELECT
           DATE(created_at) as date,
           COUNT(*) as order_count,
           COALESCE(SUM(total_amount), 0) as revenue
         FROM orders
         WHERE status = 'completed'
           AND created_at >= CURRENT_DATE - INTERVAL '7 days'
         GROUP BY DATE(created_at)
         ORDER BY date''',
    );
    return rows;
  }

  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5}) async {
    final rows = await _db.query(
      '''SELECT
           oi.product_name,
           SUM(oi.quantity) as total_qty,
           SUM(oi.subtotal) as total_revenue
         FROM order_items oi
         JOIN orders o ON o.id = oi.order_id
         WHERE o.status = 'completed'
           AND o.created_at >= CURRENT_DATE - INTERVAL '30 days'
         GROUP BY oi.product_name
         ORDER BY total_qty DESC
         LIMIT @limit''',
      params: {'limit': limit},
    );
    return rows;
  }

  Future<List<Map<String, dynamic>>> getMonthlySales() async {
    final rows = await _db.query(
      '''SELECT
           TO_CHAR(created_at, 'Mon') as month,
           EXTRACT(MONTH FROM created_at) as month_num,
           COUNT(*) as order_count,
           COALESCE(SUM(total_amount), 0) as revenue
         FROM orders
         WHERE status = 'completed'
           AND created_at >= DATE_TRUNC('year', CURRENT_DATE)
         GROUP BY month, month_num
         ORDER BY month_num''',
    );
    return rows;
  }

  Future<bool> cancelOrder(int id) async {
    final affected = await _db.execute(
      "UPDATE orders SET status = 'cancelled' WHERE id = @id",
      params: {'id': id},
    );
    return affected > 0;
  }
}
