import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/category.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/pos_provider.dart';
import '../../widgets/cart_item_widget.dart';
import '../../widgets/payment_dialog.dart';
import '../../widgets/product_card.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _searchCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  final _tableCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _customerCtrl.dispose();
    _tableCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 6, child: _buildProductPanel()),
        Container(width: 1, color: AppColors.border),
        SizedBox(width: 360, child: _buildCartPanel()),
      ],
    );
  }

  Widget _buildProductPanel() {
    return Consumer<MenuProvider>(
      builder: (context, menu, _) {
        return Column(
          children: [
            _buildTopBar(menu),
            _buildCategoryTabs(menu),
            Expanded(child: _buildProductGrid(menu)),
          ],
        );
      },
    );
  }

  Widget _buildTopBar(MenuProvider menu) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kasir',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${menu.filteredProducts.where((p) => p.isAvailable).length} menu tersedia',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 260,
            child: TextField(
              controller: _searchCtrl,
              onChanged: menu.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Cari menu...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          menu.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(MenuProvider menu) {
    final categories = [categoryAll, ...menu.categories];
    return Container(
      height: 50,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = menu.selectedCategory.id == cat.id;
          return _CategoryChip(
            category: cat,
            isSelected: isSelected,
            onTap: () => menu.selectCategory(cat),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(MenuProvider menu) {
    if (menu.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (menu.error != null) {
      return _ErrorView(
        message: menu.error!,
        onRetry: menu.loadAll,
      );
    }

    final products = menu.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              'Menu tidak ditemukan',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Consumer<PosProvider>(
      builder: (context, pos, _) {
        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 220,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: products.length,
          itemBuilder: (_, i) {
            final product = products[i];
            final entry = pos.cart.firstWhere(
              (e) => e.product.id == product.id,
              orElse: () => CartEntry(product: product, quantity: 0),
            );
            return ProductCard(
              product: product,
              cartQuantity: entry.quantity,
              onTap: () => pos.addToCart(product),
            );
          },
        );
      },
    );
  }

  Widget _buildCartPanel() {
    return Consumer<PosProvider>(
      builder: (context, pos, _) {
        return Container(
          color: AppColors.surface,
          child: Column(
            children: [
              _buildCartHeader(pos),
              if (pos.isEmpty)
                const Expanded(child: _EmptyCart())
              else ...[
                _buildCustomerInfo(pos),
                Expanded(child: _buildCartList(pos)),
                _buildCartSummary(pos),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartHeader(PosProvider pos) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            const Icon(Icons.shopping_cart_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Text(
              'Pesanan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (pos.itemCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${pos.itemCount}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (!pos.isEmpty)
              TextButton.icon(
                onPressed: () => _confirmClearCart(pos),
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Hapus'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
      );

  Widget _buildCustomerInfo(PosProvider pos) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customerCtrl,
                onChanged: (v) => pos.setCustomerInfo(
                  name: v,
                  table: _tableCtrl.text,
                ),
                decoration: const InputDecoration(
                  hintText: 'Nama pelanggan',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _tableCtrl,
                onChanged: (v) => pos.setCustomerInfo(
                  name: _customerCtrl.text,
                  table: v,
                ),
                decoration: const InputDecoration(
                  hintText: 'Meja',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
          ],
        ),
      );

  Widget _buildCartList(PosProvider pos) => ListView.builder(
        itemCount: pos.cart.length,
        itemBuilder: (_, i) {
          final entry = pos.cart[i];
          return CartItemWidget(
            entry: entry,
            onIncrease: () => pos.increaseQty(entry.product.id),
            onDecrease: () => pos.decreaseQty(entry.product.id),
            onRemove: () => pos.removeFromCart(entry.product.id),
          );
        },
      );

  Widget _buildCartSummary(PosProvider pos) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Column(
          children: [
            _SummaryLine('Subtotal', CurrencyFormatter.format(pos.subtotal)),
            const SizedBox(height: 4),
            _SummaryLine(
              'PPN (11%)',
              CurrencyFormatter.format(pos.taxAmount),
              secondary: true,
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            _SummaryLine(
              'Total',
              CurrencyFormatter.format(pos.total),
              large: true,
              primary: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pos.isLoading ? null : () => _openPayment(pos),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: pos.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Proses Pembayaran',
                            style: GoogleFonts.poppins(
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
        ),
      );

  Future<void> _openPayment(PosProvider pos) async {
    final order = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PaymentDialog(),
    );
    if (order != null && mounted) {
      _customerCtrl.clear();
      _tableCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pesanan berhasil! ${order.orderNumber}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmClearCart(PosProvider pos) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Pesanan?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Semua item di keranjang akan dihapus.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      pos.clearCart();
      _customerCtrl.clear();
      _tableCtrl.clear();
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                category.name,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool secondary;
  final bool large;
  final bool primary;

  const _SummaryLine(
    this.label,
    this.value, {
    this.secondary = false,
    this.large = false,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: large ? 15 : 13,
              fontWeight: large ? FontWeight.w600 : FontWeight.w400,
              color: secondary
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: large ? 18 : 13,
              fontWeight: large ? FontWeight.w700 : FontWeight.w500,
              color: primary ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      );
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          Text(
            'Keranjang kosong',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih menu untuk mulai\nmembuat pesanan',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textHint,
            ),
          ),
        ],
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Koneksi gagal',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
}
