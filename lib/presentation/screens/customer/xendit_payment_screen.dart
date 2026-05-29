import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/order.dart';
import '../../../providers/pos_provider.dart';
import '../pos/pos_screen.dart';
import '../../widgets/receipt_preview_dialog.dart';

class XenditPaymentScreen extends StatefulWidget {
  final String customerName;
  final String tableNumber;
  final double amount;

  const XenditPaymentScreen({
    super.key,
    required this.customerName,
    required this.tableNumber,
    required this.amount,
  });

  @override
  State<XenditPaymentScreen> createState() => _XenditPaymentScreenState();
}

class _XenditPaymentScreenState extends State<XenditPaymentScreen> {
  late Timer _timer;
  int _secondsLeft = 600; // 10 minutes
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer.cancel();
        Navigator.pop(context); // Expired
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsLeft / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.read<PosProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/e/e0/Xendit_Logo.png',
          height: 24,
          errorBuilder: (_, __, ___) => Text(
            'Xendit Payment Gateway',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: const Color(0xFF5C26FF)),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 420,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Merchant Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5C26FF),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'KOPI NUSANTARA',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Invoice Meja ${widget.tableNumber}',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Timer
                      Text(
                        'Selesaikan pembayaran dalam',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: AppColors.error),
                          const SizedBox(width: 4),
                          Text(
                            _formattedTime,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // QRIS Code Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'QRIS GPN DYNAMIC',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.blue[900],
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Simulated QR Code vector
                            Container(
                              width: 200,
                              height: 200,
                              color: Colors.black,
                              padding: const EdgeInsets.all(8),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 10,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                ),
                                itemCount: 100,
                                itemBuilder: (context, idx) {
                                  // Simulated QR patterns
                                  final isDark = (idx < 20 && idx % 3 == 0) ||
                                      (idx > 80 && idx % 2 == 0) ||
                                      (idx % 7 == 0) ||
                                      (idx % 11 == 0) ||
                                      (idx > 30 && idx < 40) ||
                                      (idx > 60 && idx < 70 && idx % 3 == 0);
                                  return Container(
                                    color: isDark ? Colors.black : Colors.white,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Pindai menggunakan M-Banking atau E-Wallet Anda',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Invoice Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Tagihan',
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                          ),
                          Text(
                            CurrencyFormatter.format(widget.amount),
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF5C26FF),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // Simulator Webhook / Pay Action
                      ElevatedButton(
                        onPressed: _isProcessing ? null : () => _simulatPay(pos),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C26FF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Simulasikan Webhook Sukses',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text('Batalkan Pesanan'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _simulatPay(PosProvider pos) async {
    setState(() {
      _isProcessing = true;
    });

    // Make database submission via provider (Checkout with QRIS method)
    final order = await pos.checkout(
      paymentMethod: PaymentMethod.qris,
      paymentAmount: widget.amount,
    );

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });

    if (order != null) {
      _timer.cancel();
      // Show thermal receipt
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ReceiptPreviewDialog(order: order),
      );
      if (mounted) {
        Navigator.pop(context, order); // Go back with created order
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan memproses pesanan.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
