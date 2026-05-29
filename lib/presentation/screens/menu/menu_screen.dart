import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../data/models/category.dart';
import '../../../data/models/product.dart';
import '../../../providers/menu_provider.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _searchCtrl = TextEditingController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menu, _) {
        return Column(
          children: [
            _buildHeader(menu),
            Expanded(child: _buildContent(menu)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(MenuProvider menu) => Container(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
        color: AppColors.surface,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manajemen Menu',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${menu.products.length} item terdaftar',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 240,
              child: TextField(
                controller: _searchCtrl,
                onChanged: menu.setSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Cari menu...',
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showProductForm(context, menu),
              icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
              label: Text(
                'Tambah Menu',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      );

  Widget _buildContent(MenuProvider menu) {
    if (menu.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final products = menu.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu_rounded,
                size: 56, color: AppColors.border),
            const SizedBox(height: 16),
            Text(
              'Belum ada menu',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Klik "Tambah Menu" untuk mulai menambahkan produk',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(28),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _MenuListItem(
        product: products[i],
        category: menu.getCategoryById(products[i].categoryId),
        onEdit: () => _showProductForm(context, menu, product: products[i]),
        onToggle: (v) => menu.toggleAvailability(products[i].id, v),
        onDelete: () => _confirmDelete(context, menu, products[i]),
      ),
    );
  }

  Future<void> _showProductForm(
    BuildContext context,
    MenuProvider menu, {
    Product? product,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => _ProductFormDialog(
        menu: menu,
        product: product,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MenuProvider menu,
    Product product,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Menu?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Menu "${product.name}" akan dihapus permanen.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
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
      await menu.deleteProduct(product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Menu dihapus', style: GoogleFonts.inter()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _MenuListItem extends StatelessWidget {
  final Product product;
  final Category? category;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _MenuListItem({
    required this.product,
    this.category,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  IconHelper.getCategoryIcon(category?.name ?? ''),
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (product.description != null)
                    Text(
                      product.description!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (category != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category!.name,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        CurrencyFormatter.format(product.price),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Switch(
              value: product.isAvailable,
              onChanged: onToggle,
              activeColor: AppColors.success,
              thumbColor: WidgetStateProperty.all(Colors.white),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionBtn(
                    icon: Icons.edit_rounded,
                    color: AppColors.primary,
                    onTap: onEdit,
                  ),
                  _ActionBtn(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.error,
                    onTap: onDelete,
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

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        splashRadius: 20,
      );
}

class _ProductFormDialog extends StatefulWidget {
  final MenuProvider menu;
  final Product? product;

  const _ProductFormDialog({required this.menu, this.product});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  Category? _selectedCategory;
  bool _isAvailable = true;
  bool _isSaving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.product!;
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description ?? '';
      _priceCtrl.text = p.price.toInt().toString();
      _isAvailable = p.isAvailable;
      _selectedCategory = widget.menu.getCategoryById(p.categoryId);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 480,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                const SizedBox(height: 24),
                _buildNameField(),
                const SizedBox(height: 14),
                _buildDescField(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildPriceField()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCategoryDropdown()),
                  ],
                ),
                const SizedBox(height: 14),
                _buildAvailabilityToggle(),
                const SizedBox(height: 24),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() => Row(
        children: [
          Icon(
            _isEdit ? Icons.edit_rounded : Icons.add_circle_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Text(
            _isEdit ? 'Edit Menu' : 'Tambah Menu Baru',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
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

  Widget _buildNameField() => TextFormField(
        controller: _nameCtrl,
        decoration: const InputDecoration(
          labelText: 'Nama Menu *',
          hintText: 'contoh: Cappuccino',
        ),
        validator: (v) =>
            v == null || v.isEmpty ? 'Nama menu wajib diisi' : null,
      );

  Widget _buildDescField() => TextFormField(
        controller: _descCtrl,
        maxLines: 2,
        decoration: const InputDecoration(
          labelText: 'Deskripsi',
          hintText: 'Deskripsi singkat menu...',
        ),
      );

  Widget _buildPriceField() => TextFormField(
        controller: _priceCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          labelText: 'Harga (Rp) *',
          hintText: '25000',
          prefixText: 'Rp ',
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Harga wajib diisi';
          if (double.tryParse(v) == null) return 'Format tidak valid';
          return null;
        },
      );

  Widget _buildCategoryDropdown() {
    final categories = widget.menu.categories;
    return DropdownButtonFormField<Category>(
      value: _selectedCategory,
      onChanged: (v) => setState(() => _selectedCategory = v),
      decoration: const InputDecoration(labelText: 'Kategori'),
      hint: Text('Pilih kategori',
          style: GoogleFonts.inter(fontSize: 13)),
      items: categories
          .map((c) => DropdownMenuItem(
                value: c,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconHelper.getCategoryIcon(c.name),
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      c.name,
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildAvailabilityToggle() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _isAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: _isAvailable ? AppColors.success : AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _isAvailable ? AppColors.success : AppColors.error,
                ),
              ),
            ),
            Switch(
              value: _isAvailable,
              onChanged: (v) => setState(() => _isAvailable = v),
              activeColor: AppColors.success,
            ),
          ],
        ),
      );

  Widget _buildButtons() => Row(
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
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _isEdit ? 'Simpan Perubahan' : 'Tambah Menu',
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final price = double.parse(_priceCtrl.text);
    bool ok;

    if (_isEdit) {
      ok = await widget.menu.updateProduct(widget.product!.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        price: price,
        categoryId: _selectedCategory?.id,
        isAvailable: _isAvailable,
      ));
    } else {
      ok = await widget.menu.addProduct(
        name: _nameCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        price: price,
        categoryId: _selectedCategory?.id,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Menu berhasil diperbarui' : 'Menu berhasil ditambahkan',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
