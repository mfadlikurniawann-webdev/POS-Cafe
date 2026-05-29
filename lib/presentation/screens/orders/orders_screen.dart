import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/order.dart';
import '../../../providers/order_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, op, _) {
        return Column(
          children: [
            _buildHeader(op),
            Expanded(child: _buildContent(op)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(OrderProvider op) => Container(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
        color: AppColors.surface,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Riwayat Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${op.orders.length} transaksi',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => op.loadOrders(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );

  Widget _buildContent(OrderProvider op) {
    if (op.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (op.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 56, color: AppColors.border),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesanan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(28),
      itemCount: op.orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _OrderCard(
        order: op.orders[i],
        onViewDetail: () => _showDetail(context, op.orders[i]),
      ),
    );
  }

  void _showDetail(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (_) => _OrderDetailDialog(order: order),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onViewDetail;

  const _OrderCard({required this.order, required this.onViewDetail});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onViewDetail,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.orderNumber,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _StatusBadge(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (order.customerName != null) ...[
                          Icon(Icons.person_outline_rounded,
                              size: 13, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            order.customerName!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (order.tableNumber != null) ...[
                          Icon(Icons.table_bar_rounded,
                              size: 13, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            'Meja ${order.tableNumber}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(Icons.access_time_rounded,
                            size: 13, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          order.createdAt != null
                              ? DateFormat('dd MMM, HH:mm').format(
                                  order.createdAt!.toLocal())
                              : '-',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.items.length} item · ${_payMethodLabel(order.paymentMethod)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(order.totalAmount),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.textHint),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.processing:
        return AppColors.info;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _payMethodLabel(PaymentMethod? method) {
    if (method == null) return '-';
    return method.label;
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      OrderStatus.completed => (AppColors.success, AppColors.successLight),
      OrderStatus.pending => (AppColors.warning, AppColors.warningLight),
      OrderStatus.processing => (AppColors.info, AppColors.infoLight),
      OrderStatus.cancelled => (AppColors.error, AppColors.errorLight),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _OrderDetailDialog extends StatelessWidget {
  final Order order;

  const _OrderDetailDialog({required this.order});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 480,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildInfo(),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildItemsList(),
              const Divider(),
              const SizedBox(height: 12),
              _buildTotals(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Row(
        children: [
          const Icon(Icons.receipt_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              order.orderNumber,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _StatusBadge(status: order.status),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.textSecondary,
          ),
        ],
      );

  Widget _buildInfo() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (order.customerName != null)
              _InfoItem(
                  Icons.person_rounded, 'Pelanggan', order.customerName!),
            if (order.tableNumber != null) ...[
              const SizedBox(width: 16),
              _InfoItem(Icons.table_bar_rounded, 'Meja', order.tableNumber!),
            ],
            const Spacer(),
            _InfoItem(
              Icons.payment_rounded,
              'Pembayaran',
              order.paymentMethod?.label ?? '-',
            ),
            if (order.createdAt != null) ...[
              const SizedBox(width: 16),
              _InfoItem(
                Icons.access_time_rounded,
                'Waktu',
                DateFormat('dd MMM yyyy, HH:mm')
                    .format(order.createdAt!.toLocal()),
              ),
            ],
          ],
        ),
      );

  Widget _buildItemsList() => Column(
        children: order.items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.productName,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.subtotal),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );

  Widget _buildTotals() => Column(
        children: [
          _TotalRow('Subtotal', CurrencyFormatter.format(order.subtotal)),
          const SizedBox(height: 4),
          _TotalRow('PPN', CurrencyFormatter.format(order.taxAmount),
              secondary: true),
          const SizedBox(height: 10),
          _TotalRow(
            'Total',
            CurrencyFormatter.format(order.totalAmount),
            bold: true,
            primary: true,
          ),
          if (order.paymentAmount != null) ...[
            const SizedBox(height: 4),
            _TotalRow(
                'Dibayar', CurrencyFormatter.format(order.paymentAmount!),
                secondary: true),
            _TotalRow(
              'Kembalian',
              CurrencyFormatter.format(order.changeAmount),
              secondary: true,
            ),
          ],
        ],
      );
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool primary;
  final bool secondary;

  const _TotalRow(
    this.label,
    this.value, {
    this.bold = false,
    this.primary = false,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: secondary
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: bold ? 16 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: primary ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      );
}
