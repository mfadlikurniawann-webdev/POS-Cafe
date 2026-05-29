class OrderItem {
  final int? id;
  final int? orderId;
  final int? productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? notes;

  const OrderItem({
    this.id,
    this.orderId,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.notes,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        id: map['id'] as int?,
        orderId: map['order_id'] as int?,
        productId: map['product_id'] as int?,
        productName: map['product_name'] as String,
        quantity: map['quantity'] as int,
        unitPrice: double.parse(map['unit_price'].toString()),
        subtotal: double.parse(map['subtotal'].toString()),
        notes: map['notes'] as String?,
      );

  OrderItem copyWith({int? quantity, String? notes}) => OrderItem(
        id: id,
        orderId: orderId,
        productId: productId,
        productName: productName,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice,
        subtotal: unitPrice * (quantity ?? this.quantity),
        notes: notes ?? this.notes,
      );
}
