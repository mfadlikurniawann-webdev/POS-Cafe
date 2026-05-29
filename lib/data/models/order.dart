import 'order_item.dart';

enum OrderStatus { pending, processing, completed, cancelled }

enum PaymentMethod { cash, card, qris, transfer }

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Menunggu';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  String get value => name;

  static OrderStatus fromString(String s) =>
      OrderStatus.values.firstWhere((e) => e.name == s,
          orElse: () => OrderStatus.pending);
}

extension PaymentMethodExt on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.card:
        return 'Kartu';
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.transfer:
        return 'Transfer';
    }
  }

  String get value => name;

  static PaymentMethod fromString(String s) =>
      PaymentMethod.values.firstWhere((e) => e.name == s,
          orElse: () => PaymentMethod.cash);
}

class Order {
  final int? id;
  final String orderNumber;
  final OrderStatus status;
  final double totalAmount;
  final double taxAmount;
  final double discountAmount;
  final PaymentMethod? paymentMethod;
  final double? paymentAmount;
  final double changeAmount;
  final String? customerName;
  final String? tableNumber;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final List<OrderItem> items;

  const Order({
    this.id,
    required this.orderNumber,
    this.status = OrderStatus.pending,
    required this.totalAmount,
    this.taxAmount = 0,
    this.discountAmount = 0,
    this.paymentMethod,
    this.paymentAmount,
    this.changeAmount = 0,
    this.customerName,
    this.tableNumber,
    this.notes,
    this.createdAt,
    this.completedAt,
    this.items = const [],
  });

  double get subtotal => totalAmount - taxAmount + discountAmount;
  double get grandTotal => totalAmount;

  factory Order.fromMap(Map<String, dynamic> map, {List<OrderItem>? items}) =>
      Order(
        id: map['id'] as int?,
        orderNumber: map['order_number'] as String,
        status: OrderStatusExt.fromString(map['status'] as String? ?? 'pending'),
        totalAmount: double.parse(map['total_amount'].toString()),
        taxAmount: double.parse(map['tax_amount']?.toString() ?? '0'),
        discountAmount:
            double.parse(map['discount_amount']?.toString() ?? '0'),
        paymentMethod: map['payment_method'] != null
            ? PaymentMethodExt.fromString(map['payment_method'] as String)
            : null,
        paymentAmount: map['payment_amount'] != null
            ? double.parse(map['payment_amount'].toString())
            : null,
        changeAmount:
            double.parse(map['change_amount']?.toString() ?? '0'),
        customerName: map['customer_name'] as String?,
        tableNumber: map['table_number'] as String?,
        notes: map['notes'] as String?,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'].toString())
            : null,
        completedAt: map['completed_at'] != null
            ? DateTime.parse(map['completed_at'].toString())
            : null,
        items: items ?? [],
      );
}
