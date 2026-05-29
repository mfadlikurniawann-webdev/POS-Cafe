import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../data/models/category.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/pos_provider.dart';
import '../../widgets/cart_item_widget.dart';
import '../../widgets/product_card.dart';
import 'xendit_payment_screen.dart';

class CustomerOrderScreen extends StatefulWidget {
  final VoidCallback onExit;

  const CustomerOrderScreen({super.key, required this.onExit});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  final _customerCtrl = TextEditingController();
  final _tableCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadAll();
      // Ensure cart is clean for new customer session
      context.read<PosProvider>().clearCart();
    });
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    _tableCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final pos = context.watch<PosProvider>();
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Pemesanan Mandiri',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: widget.onExit,
            icon: const Icon(Icons.exit_to_app_rounded, size: 18),
            label: const Text('Mode Kasir'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildInfoBanner(pos),
          _buildSearchAndCategories(menu),
          Expanded(
            child: _buildProductGrid(menu, pos),
          ),
        ],
      ),
      bottomNavigationBar: pos.itemCount > 0
          ? _buildBottomActionBar(context, pos, isMobile)
          : null,
    );
  }

  Widget _buildInfoBanner(PosProvider pos) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _customerCtrl,
              onChanged: (val) => pos.setCustomerInfo(
                name: val,
                table: _tableCtrl.text,
              ),
              decoration: const InputDecoration(
                labelText: 'Nama Pelanggan *',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: _tableCtrl,
              keyboardType: TextInputType.number,
              onChanged: (val) => pos.setCustomerInfo(
                name: _customerCtrl.text,
                table: val,
              ),
              decoration: const InputDecoration(
                labelText: 'No. Meja *',
                prefixIcon: Icon(Icons.table_restaurant_rounded, size: 18),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndCategories(MenuProvider menu) {
    final categories = [categoryAll, ...menu.categories];
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: menu.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Cari kopi atau makanan favoritmu...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          menu.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = categories[i];
                final isSelected = menu.selectedCategory.id == cat.id;
                return GestureDetector(
                  onTap: () => menu.selectCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          IconHelper.getCategoryIcon(cat.name),
                          size: 16,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildProductGrid(MenuProvider menu, PosProvider pos) {
    if (menu.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final products = menu.filteredProducts.where((p) => p.isAvailable).toList();

    if (products.isEmpty) {
      return Center(
        child: Text(
          'Menu tidak ditemukan.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisExtent: 220,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
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
  }

  Widget _buildBottomActionBar(BuildContext context, PosProvider pos, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pos.itemCount} Item terpilih',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(pos.total),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => _showOrderReview(context, pos),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              child: Text(
                'Lanjut Pembayaran',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderReview(BuildContext context, PosProvider pos) {
    if (_customerCtrl.text.trim().isEmpty || _tableCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan lengkapi Nama Pelanggan & Nomor Meja terlebih dahulu.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Konfirmasi Pesanan',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: pos.cart.length,
                itemBuilder: (context, i) {
                  final entry = pos.cart[i];
                  return CartItemWidget(
                    entry: entry,
                    onIncrease: () => pos.increaseQty(entry.product.id),
                    onDecrease: () => pos.decreaseQty(entry.product.id),
                    onRemove: () => pos.removeFromCart(entry.product.id),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: GoogleFonts.inter(fontSize: 13)),
                      Text(CurrencyFormatter.format(pos.subtotal), style: GoogleFonts.inter(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PPN (11%)', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                      Text(CurrencyFormatter.format(pos.taxAmount), style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Bayar',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        CurrencyFormatter.format(pos.total),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx); // Close sheet
                        
                        // Proceed to Xendit Payment screen
                        final order = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => XenditPaymentScreen(
                              customerName: _customerCtrl.text.trim(),
                              tableNumber: _tableCtrl.text.trim(),
                              amount: pos.total,
                            ),
                          ),
                        );

                        if (order != null && context.mounted) {
                          _customerCtrl.clear();
                          _tableCtrl.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pembayaran Mandiri Sukses! No. Pesanan: ${order.orderNumber}'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Bayar via Xendit (QRIS / E-Wallet)',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
