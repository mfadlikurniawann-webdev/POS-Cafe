import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/order.dart';
import '../../../providers/pos_provider.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.security_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Pembayaran Aman',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            width: 440,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Merchant Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent, width: 1),
                        ),
                        child: Text(
                          'KOPI NUSANTARA',
                          style: GoogleFonts.inter(
                            color: AppColors.accentLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Invoice Meja ${widget.tableNumber}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Atas Nama: ${widget.customerName}',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      // Timer
                      Text(
                        'Selesaikan Pembayaran Dalam',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer_outlined, size: 16, color: AppColors.error),
                            const SizedBox(width: 6),
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
                      ),
                      const SizedBox(height: 24),

                      // QRIS Premium Card Box
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // QRIS Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/a/a2/Logo_QRIS.svg',
                                  height: 22,
                                  errorBuilder: (_, __, ___) => Text(
                                    'QRIS',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1B4E9B),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[900],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'GPN',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Simulated QR Code vector with Center QRIS logo
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 220,
                                  height: 220,
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(12),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 12,
                                      crossAxisSpacing: 2,
                                      mainAxisSpacing: 2,
                                    ),
                                    itemCount: 144,
                                    itemBuilder: (context, idx) {
                                      // Border coordinates (QR corner anchor points)
                                      final isCorner = (idx < 4 || (idx >= 8 && idx < 12)) && (idx % 12 < 4 || idx % 12 >= 8);
                                      // Simulated random QR noise
                                      final isNoise = (idx * 17) % 3 == 0 || (idx * 23) % 5 == 0;
                                      // Avoid center area for overlay logo
                                      final isCenter = (idx ~/ 12 >= 4 && idx ~/ 12 <= 7) && (idx % 12 >= 4 && idx % 12 <= 7);
                                      
                                      final isDark = !isCenter && (isCorner || isNoise);
                                      return Container(
                                        color: isDark ? AppColors.primaryDark : Colors.white,
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    'QRIS',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Pindai dengan aplikasi pembayaran digital pilihan Anda seperti GoPay, OVO, DANA, LinkAja, atau M-Banking.',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Premium Invoice Ticket Divider
                      Row(
                        children: List.generate(
                          20,
                          (index) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Container(
                                height: 2,
                                color: AppColors.border,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Invoice Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Pembayaran',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(widget.amount),
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Actions
                      ElevatedButton(
                        onPressed: _isProcessing ? null : () => _simulatePay(pos),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Simulasikan Webhook Sukses',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: AppColors.textSecondary,
                          ),
                          child: Text(
                            'Batalkan Pesanan',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            'Secured by Xendit Payment Gateway',
                            style: GoogleFonts.inter(fontSize: 10, color: AppColors.textHint),
                          ),
                        ],
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

  Future<void> _simulatePay(PosProvider pos) async {
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

