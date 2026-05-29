import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/order.dart';
import '../../providers/pos_provider.dart';

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({super.key});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  PaymentMethod _method = PaymentMethod.cash;
  final _payController = TextEditingController();
  double _payAmount = 0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _payController.dispose();
    super.dispose();
  }

  double get change {
    final pos = context.read<PosProvider>();
    return _payAmount - pos.total;
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildOrderSummary(pos),
            const SizedBox(height: 20),
            _buildPaymentMethods(),
            if (_method == PaymentMethod.cash) ...[
              const SizedBox(height: 16),
              _buildCashInput(pos),
            ],
            const SizedBox(height: 24),
            _buildActions(pos),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
        children: [
          const Icon(Icons.payment_rounded,
              color: AppColors.primary, size: 24),
          const SizedBox(width: 10),
          Text(
            'Proses Pembayaran',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.textSecondary,
          ),
        ],
      );

  Widget _buildOrderSummary(PosProvider pos) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _SummaryRow('Subtotal', CurrencyFormatter.format(pos.subtotal)),
            const SizedBox(height: 6),
            _SummaryRow(
              'PPN (11%)',
              CurrencyFormatter.format(pos.taxAmount),
              textColor: AppColors.textSecondary,
            ),
            const Divider(height: 16),
            _SummaryRow(
              'Total',
              CurrencyFormatter.format(pos.total),
              isBold: true,
              textColor: AppColors.primary,
            ),
            if (_method == PaymentMethod.cash && change >= 0) ...[
              const SizedBox(height: 6),
              _SummaryRow(
                'Kembalian',
                CurrencyFormatter.format(change),
                textColor: AppColors.success,
                isBold: true,
              ),
            ],
          ],
        ),
      );

  Widget _buildPaymentMethods() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metode Pembayaran',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: PaymentMethod.values.map((m) {
              final isSelected = _method == m;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _PayMethodBtn(
                    method: m,
                    isSelected: isSelected,
                    onTap: () => setState(() {
                      _method = m;
                      if (m != PaymentMethod.cash) _payAmount = 0;
                    }),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );

  Widget _buildCashInput(PosProvider pos) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jumlah Uang Diterima',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _payController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) =>
                setState(() => _payAmount = double.tryParse(v) ?? 0),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              hintText: '0',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickAmounts(pos.total)
                .map((amount) => _QuickBtn(
                      label: CurrencyFormatter.compact(amount),
                      onTap: () {
                        setState(() {
                          _payAmount = amount;
                          _payController.text = amount.toInt().toString();
                        });
                      },
                    ))
                .toList(),
          ),
        ],
      );

  List<double> _quickAmounts(double total) {
    final rounded = (total / 10000).ceil() * 10000;
    return <double>[
      rounded.toDouble(),
      (rounded + 10000).toDouble(),
      (rounded + 50000).toDouble(),
      100000,
      200000,
    ].toSet().where((a) => a >= total).take(5).toList()
      ..sort();
  }

  Widget _buildActions(PosProvider pos) => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canPay(pos) ? () => _processPayment(pos) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Bayar Sekarang',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      );

  bool _canPay(PosProvider pos) {
    if (_isProcessing) return false;
    if (_method == PaymentMethod.cash) {
      return _payAmount >= pos.total;
    }
    return true;
  }

  Future<void> _processPayment(PosProvider pos) async {
    setState(() => _isProcessing = true);
    final payAmount =
        _method == PaymentMethod.cash ? _payAmount : pos.total;
    final order = await pos.checkout(
      paymentMethod: _method,
      paymentAmount: payAmount,
    );
    if (!mounted) return;
    Navigator.pop(context, order);
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? textColor;

  const _SummaryRow(
    this.label,
    this.value, {
    this.isBold = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      );
}

class _PayMethodBtn extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  static const Map<PaymentMethod, IconData> _icons = {
    PaymentMethod.cash: Icons.payments_rounded,
    PaymentMethod.card: Icons.credit_card_rounded,
    PaymentMethod.qris: Icons.qr_code_rounded,
    PaymentMethod.transfer: Icons.account_balance_rounded,
  };

  static const Map<PaymentMethod, Color> _colors = {
    PaymentMethod.cash: AppColors.cash,
    PaymentMethod.card: AppColors.card,
    PaymentMethod.qris: AppColors.qris,
    PaymentMethod.transfer: AppColors.transfer,
  };

  const _PayMethodBtn({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colors[method]!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _icons[method],
              color: isSelected ? color : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              method.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      );
}
