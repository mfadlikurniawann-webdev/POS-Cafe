import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/order.dart';

class ReceiptPreviewDialog extends StatelessWidget {
  final Order order;

  const ReceiptPreviewDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final formattedDate = order.createdAt != null
        ? DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(order.createdAt!)
        : DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(DateTime.now());

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Receipt Body
              Container(
                width: 380,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Top wave/tear simulator (represented cleanly by small circles)
                    Row(
                      children: List.generate(
                        19,
                        (index) => Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Center(
                            child: Text(
                              'KOPI NUSANTARA',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Premium Coffee & Roastery',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Jl. Merdeka No. 45, Jakarta',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDashedLine(),
                          const SizedBox(height: 12),

                          // Metadata
                          _buildMetaRow('No. Transaksi', order.orderNumber),
                          _buildMetaRow('Tanggal', formattedDate),
                          _buildMetaRow('Kasir', 'Staff POS'),
                          _buildMetaRow(
                            'Tipe',
                            order.tableNumber != null && order.tableNumber!.isNotEmpty
                                ? 'Dine-in (Meja ${order.tableNumber})'
                                : 'Takeaway',
                          ),
                          if (order.customerName != null && order.customerName!.isNotEmpty)
                            _buildMetaRow('Pelanggan', order.customerName!),

                          const SizedBox(height: 12),
                          _buildDashedLine(),
                          const SizedBox(height: 12),

                          // Items List
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: order.items.length,
                            itemBuilder: (context, i) {
                              final item = order.items[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.productName,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          CurrencyFormatter.format(item.subtotal),
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.quantity} x ${CurrencyFormatter.format(item.unitPrice)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (item.notes != null && item.notes!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          'Catatan: ${item.notes}',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 6),
                          _buildDashedLine(),
                          const SizedBox(height: 12),

                          // Summary Details
                          _buildPriceRow('Subtotal', order.subtotal),
                          _buildPriceRow('PPN (11%)', order.taxAmount),
                          if (order.discountAmount > 0)
                            _buildPriceRow('Diskon', -order.discountAmount, isDiscount: true),
                          const SizedBox(height: 6),
                          _buildPriceRow('TOTAL', order.totalAmount, isBold: true),
                          _buildDashedLine(),
                          const SizedBox(height: 12),

                          // Payment & Change Info
                          _buildMetaRow('Metode Pembayaran', order.paymentMethod?.label ?? 'Tunai'),
                          _buildPriceRow('Dibayar', order.paymentAmount ?? order.totalAmount),
                          _buildPriceRow('Kembalian', order.changeAmount, isBold: order.changeAmount > 0),

                          const SizedBox(height: 20),
                          _buildDashedLine(),
                          const SizedBox(height: 20),

                          // Brand Tagline
                          Center(
                            child: Text(
                              'Terima Kasih Atas Kunjungan Anda',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              'Powered by Kopi Nusantara POS',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Simulated Barcode
                          Center(
                            child: Container(
                              height: 40,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  32,
                                  (index) => Container(
                                    width: (index % 3 == 0) ? 2 : ((index % 5 == 0) ? 4 : 1),
                                    color: (index % 7 == 0) ? Colors.transparent : Colors.black87,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom tear effect
                    Row(
                      children: List.generate(
                        19,
                        (index) => Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Simulasi Cetak: Struk dikirim ke Printer Thermal.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.print_rounded, color: Colors.white),
                    label: const Text('Cetak Struk'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          Text(
            isDiscount
                ? '-${CurrencyFormatter.format(value.abs())}'
                : CurrencyFormatter.format(value),
            style: GoogleFonts.inter(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: isDiscount ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
