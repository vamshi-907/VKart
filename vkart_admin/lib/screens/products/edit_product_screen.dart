import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vkart_shared/vkart_shared.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/products_provider.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_brand_autocomplete.dart';
import 'package:vkart_admin/widgets/vkart_button.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_category_selector.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_text_field.dart';

/// Edit/Delete screen for a single product.
///
/// Loads the product from the shared ProductsProvider and saves changes
/// directly to Firestore via the single AdminProductRepository. Deleting a
/// product permanently removes the document from Firestore. After both
/// operations the Product List refreshes automatically via the realtime
/// stream.
class EditProductScreen extends StatefulWidget {
  final String productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  ProductModel? _product;

  // Controllers
  late final TextEditingController _name;
  late final TextEditingController _nameTelugu;
  late final TextEditingController _description;
  late final TextEditingController _descriptionTelugu;
  late final TextEditingController _deliveryTime;
  late final TextEditingController _gst;
  late final TextEditingController _mrp;
  late final TextEditingController _price;
  late final TextEditingController _offerPrice;
  late final TextEditingController _stock;
  late final TextEditingController _sku;
  late final TextEditingController _weight;

  // Distinct categories & brands derived from the products collection.
  List<String> _categories = [];
  List<String> _brands = [];

  late String? _selectedCategory;
  late String? _selectedBrand;
  bool _active = true;

  // One editable URL field per product image. URLs are stored directly in
  // Firestore — the Admin app never uploads image files. Existing URLs are
  // pre-filled and stay untouched unless the admin edits them.
  late final List<TextEditingController> _imageUrlControllers;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductsProvider>();
    _product =
        provider.products.where((p) => p.id == widget.productId).firstOrNull;

    _name = TextEditingController(text: _product?.name ?? '');
    _nameTelugu = TextEditingController(text: _product?.nameTelugu ?? '');
    _description = TextEditingController(text: _product?.description ?? '');
    _descriptionTelugu = TextEditingController(
      text: _product?.descriptionTelugu ?? '',
    );
    _deliveryTime = TextEditingController(text: _product?.deliveryTime ?? '');

    final firstVariant = _product?.variants.isNotEmpty == true
        ? _product!.variants.first
        : null;

    _gst = TextEditingController(
      text: (_product?.gst ?? 0) == 0 ? '' : '${_product!.gst}',
    );
    _mrp = TextEditingController(
      text: (firstVariant?.mrp ?? 0) == 0 ? '' : '${firstVariant!.mrp}',
    );
    _price = TextEditingController(
      text: (firstVariant?.price ?? 0) == 0 ? '' : '${firstVariant!.price}',
    );
    _offerPrice = TextEditingController(
      text: (firstVariant?.offerPrice ?? 0) == 0
          ? ''
          : '${firstVariant!.offerPrice}',
    );
    _stock = TextEditingController(
      text: firstVariant == null ? '' : '${firstVariant.stock}',
    );
    _sku = TextEditingController(text: firstVariant?.sku ?? '');
    _weight = TextEditingController(text: firstVariant?.weight ?? '');

    _selectedCategory = _product?.categoryName ?? '';
    _selectedBrand = _product?.brandName ?? '';
    _active = _product?.active ?? true;

    // One editable URL field per existing image. URLs are stored directly in
    // Firestore — nothing is uploaded. Existing URLs stay untouched unless
    // the admin edits them.
    _imageUrlControllers = (_product?.images ?? const <String>[])
        .map((url) => TextEditingController(text: url))
        .toList();
    if (_imageUrlControllers.isEmpty) {
      _imageUrlControllers.add(TextEditingController());
    }
    for (final c in _imageUrlControllers) {
      c.addListener(_onImageUrlsChanged);
    }

    _loadOptions();
  }

  void _onImageUrlsChanged() {
    if (mounted) setState(() {});
  }

  /// Reads the products collection once and caches distinct category and brand
  /// names for the lifetime of this screen.
  void _loadOptions() {
    final products = context.read<ProductsProvider>().products;

    final categorySet = <String>{};
    final brandSet = <String>{};
    for (final p in products) {
      final cat = p.categoryName.trim();
      if (cat.isNotEmpty) categorySet.add(cat);
      final brand = p.brandName.trim();
      if (brand.isNotEmpty) brandSet.add(brand);
    }

    _categories = categorySet.toList()..sort();
    _brands = brandSet.toList()..sort();

    // Ensure the product's existing values remain selectable even if they are
    // not present among the cached distinct values.
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      _categories.add(_selectedCategory!);
      _categories = _categories.toSet().toList()..sort();
    }
    if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
      _brands.add(_selectedBrand!);
      _brands = _brands.toSet().toList()..sort();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _nameTelugu.dispose();
    _description.dispose();
    _descriptionTelugu.dispose();
    _deliveryTime.dispose();
    _gst.dispose();
    _mrp.dispose();
    _price.dispose();
    _offerPrice.dispose();
    _stock.dispose();
    _sku.dispose();
    _weight.dispose();
    for (final c in _imageUrlControllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// The non-empty, trimmed image URLs currently entered in the form.
  List<String> get _imageUrls => _imageUrlControllers
      .map((c) => c.text.trim())
      .where((url) => url.isNotEmpty)
      .toList();

  void _addImageUrlField() {
    if (_imageUrlControllers.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Up to 5 image URLs are supported')),
      );
      return;
    }
    setState(() {
      final controller = TextEditingController();
      controller.addListener(_onImageUrlsChanged);
      _imageUrlControllers.add(controller);
    });
  }

  void _removeImageUrlField(int index) {
    setState(() {
      _imageUrlControllers[index].removeListener(_onImageUrlsChanged);
      _imageUrlControllers[index].dispose();
      _imageUrlControllers.removeAt(index);
    });
  }

Future<void> _save() async {
    if (_product == null) return;
    if (!_formKey.currentState!.validate()) return;

    // The final image list is exactly what the URL fields contain. Editing
    // only product information leaves the URLs (and therefore the Firestore
    // image fields) unchanged. At least one image URL must remain.
    final imageUrls = _imageUrls;
    if (imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product image URL'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final variant = VariantModel(
      id: _product!.variants.isNotEmpty
          ? _product!.variants.first.id
          : '',
      weight: _weight.text.trim(),
      mrp: double.tryParse(_mrp.text.trim()) ?? 0,
      price: double.tryParse(_price.text.trim()) ?? 0,
      offerPrice: double.tryParse(_offerPrice.text.trim()) ??
          double.tryParse(_price.text.trim()) ??
          0,
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      sku: _sku.text.trim(),
      active: true,
    );

    final category = (_selectedCategory ?? '').trim();
    final brand = (_selectedBrand ?? '').trim();

    final updated = ProductModel(
      id: _product!.id,
      name: _name.text.trim(),
      nameTelugu: _nameTelugu.text.trim(),
      brandId: '',
      brandName: brand,
      categoryId: '',
      categoryName: category,
      subCategoryId: '',
      subCategoryName: '',
      description: _description.text.trim(),
      descriptionTelugu: _descriptionTelugu.text.trim(),
      deliveryTime: _deliveryTime.text.trim(),
gst: double.tryParse(_gst.text.trim()) ?? 0,
      images: imageUrls,
      variants: [variant],
      active: _active,
      displayOrder: _product!.displayOrder,
      createdAt: _product!.createdAt,
    );

    final productsProvider = context.read<ProductsProvider>();

    try {
      await productsProvider.updateProduct(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final msg = e.toString();
      String message;
      if (msg.contains('permission-denied')) {
        message = 'Permission denied. Please verify admin access.';
      } else if (msg.contains('firebase_storage/')) {
        message = 'Failed to upload product image. Please try again.';
      } else {
        message = 'Failed to update product. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _delete() async {
    if (_product == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: VKartColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to permanently delete "${_product!.name}"? '
          'This cannot be undone.',
          style: const TextStyle(color: VKartColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: VKartColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final productsProvider = context.read<ProductsProvider>();
        try {
      await productsProvider.deleteProduct(_product!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      final msg = e.toString();
      final message = msg.contains('permission-denied')
          ? 'Permission denied. Please verify admin access.'
          : 'Failed to delete product. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return const Scaffold(
        appBar: VKartAppBar(title: 'Edit Product'),
        body: Center(
          child: Text(
            'Product not found',
            style: TextStyle(color: VKartColors.secondaryText),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: VKartAppBar(
        title: 'Edit Product',
        subtitle: _product?.name,
        actions: [
          IconButton(
            tooltip: 'Delete',
            onPressed: _isDeleting ? null : _delete,
            icon: const Icon(Icons.delete_rounded, color: VKartColors.error),
          ),
        ],
      ),
      body: _isDeleting
          ? const VKartLoading(message: 'Deleting product...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 16),
                    _buildBasicDetailsCard(),
                    const SizedBox(height: 16),
                    _buildClassificationCard(),
                    const SizedBox(height: 16),
                    _buildPricingStockCard(),
                    const SizedBox(height: 16),
                    _buildStatusCard(),
                    const SizedBox(height: 24),
                    VKartButton(
                      text: 'Save Changes',
                      prefixIcon: Icons.save_rounded,
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                    const SizedBox(height: 8),
                    VKartButton(
                      text: 'Delete Product',
                      prefixIcon: Icons.delete_rounded,
                      isOutlined: true,
                      textColor: VKartColors.error,
                      onPressed: _delete,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

Widget _buildImageSection() {
    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Images',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VKartColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Paste direct image URLs (same as the Excel import). The URLs are '
            'stored straight into Firestore — nothing is uploaded.',
            style: TextStyle(fontSize: 12, color: VKartColors.secondaryText),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _imageUrlControllers.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VKartTextField(
                        label: 'Image URL ${i + 1}',
                        controller: _imageUrlControllers[i],
                        hint: 'https://example.com/images/product.jpg',
                      ),
                      const SizedBox(height: 8),
                      _UrlPreview(url: _imageUrlControllers[i].text.trim()),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove image URL',
                  onPressed: _imageUrlControllers.length > 1
                      ? () => _removeImageUrlField(i)
                      : null,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: VKartColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (_imageUrls.isEmpty)
            const Text(
              'At least one product image URL is required',
              style: TextStyle(color: VKartColors.error, fontSize: 12),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addImageUrlField,
            icon: const Icon(Icons.add_link_rounded),
            label: const Text('Add Image URL'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicDetailsCard() {
    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Basic Details'),
          const SizedBox(height: 16),
          VKartTextField(
            label: 'Product Name (English) *',
            controller: _name,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Name is required'
                : null,
          ),
          const SizedBox(height: 16),
          VKartTextField(
            label: 'Product Name (Telugu)',
            controller: _nameTelugu,
          ),
          const SizedBox(height: 16),
          VKartTextField(
            label: 'Description (English) *',
            controller: _description,
            maxLines: 3,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Description is required'
                : null,
          ),
          const SizedBox(height: 16),
          VKartTextField(
            label: 'Description (Telugu)',
            controller: _descriptionTelugu,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          VKartTextField(
            label: 'Delivery Time',
            controller: _deliveryTime,
            hint: 'e.g. 30 mins',
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationCard() {
    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Classification'),
          const SizedBox(height: 16),
          VKartCategorySelector(
            categories: _categories,
            initialValue: _selectedCategory,
            onChanged: (v) => setState(() => _selectedCategory = v),
          ),
          const SizedBox(height: 16),
          VKartBrandAutocomplete(
            brands: _brands,
            initialValue: _selectedBrand,
            onChanged: (v) => setState(() => _selectedBrand = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingStockCard() {
    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Pricing & Stock'),
          const SizedBox(height: 16),
          VKartTextField(
            label: 'Weight / Size *',
            controller: _weight,
            hint: 'e.g. 1 kg',
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Weight is required'
                : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: VKartTextField(
                  label: 'MRP (₹) *',
                  controller: _mrp,
                  prefixIcon: Icons.currency_rupee_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: (v) {
                    final val = double.tryParse((v ?? '').trim());
                    return (val == null || val <= 0)
                        ? 'Enter valid MRP'
                        : null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VKartTextField(
                  label: 'Price (₹) *',
                  controller: _price,
                  prefixIcon: Icons.currency_rupee_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: (v) {
                    final val = double.tryParse((v ?? '').trim());
                    return (val == null || val <= 0)
                        ? 'Enter valid price'
                        : null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: VKartTextField(
                  label: 'Offer Price (₹)',
                  controller: _offerPrice,
                  prefixIcon: Icons.local_offer_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VKartTextField(
                  label: 'Stock *',
                  controller: _stock,
                  prefixIcon: Icons.inventory_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final val = int.tryParse((v ?? '').trim());
                    return (val == null || val < 0)
                        ? 'Enter valid stock'
                        : null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: VKartTextField(
                  label: 'SKU *',
                  controller: _sku,
                  prefixIcon: Icons.qr_code_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'SKU is required'
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VKartTextField(
                  label: 'GST (%)',
                  controller: _gst,
                  prefixIcon: Icons.percent_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return VKartCard(
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: VKartColors.primary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Product Status',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: VKartColors.primaryText,
              ),
            ),
          ),
          Switch(
            value: _active,
            activeThumbColor: VKartColors.success,
            onChanged: (v) => setState(() => _active = v),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: VKartColors.primaryText,
      ),
    );
  }
}

/// Small network preview for an image URL. Never crashes the app: empty or
/// invalid URLs and any load failure simply show an "unavailable" state.
class _UrlPreview extends StatelessWidget {
  final String url;
  const _UrlPreview({required this.url});

  @override
  Widget build(BuildContext context) {
    final isHttpUrl = url.startsWith('http://') || url.startsWith('https://');
    if (!isHttpUrl) {
      return _unavailable();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 100,
            height: 100,
            color: VKartColors.hover,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _unavailable(),
      ),
    );
  }

  Widget _unavailable() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: VKartColors.hover,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VKartColors.border),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded, color: VKartColors.secondaryText),
          SizedBox(height: 4),
          Text(
            'Image preview unavailable',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: VKartColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
