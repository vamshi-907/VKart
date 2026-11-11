import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vkart_shared/vkart_shared.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/products_provider.dart';
import 'package:vkart_admin/repositories/admin_product_repository.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_brand_autocomplete.dart';
import 'package:vkart_admin/widgets/vkart_button.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_category_selector.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AdminProductRepository();

  final _nameController = TextEditingController();
  final _nameTeluguController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionTeluguController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  final _gstController = TextEditingController();
  final _mrpController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _weightController = TextEditingController();
  final _skuController = TextEditingController();

  // Distinct categories & brands derived from the products collection.
  List<String> _categories = [];
  List<String> _brands = [];

  String? _selectedCategory;
  String? _selectedBrand;
  // Each entry is one editable product image URL field. URLs are stored
  // directly in Firestore — the Admin app never uploads image files.
  final List<TextEditingController> _imageUrlControllers = [
    TextEditingController(),
  ];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
    // Re-evaluate form validity on every field change so the Save button
    // stays disabled until the entire form is valid.
    for (final c in [
      _nameController,
      _nameTeluguController,
      _descriptionController,
      _descriptionTeluguController,
      _deliveryTimeController,
      _gstController,
      _mrpController,
      _priceController,
      _stockController,
      _weightController,
      _skuController,
    ]) {
      c.addListener(_onFieldChanged);
    }
    for (final c in _imageUrlControllers) {
      c.addListener(_onFieldChanged);
    }
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

    final categories = categorySet.toList()..sort();
    final brands = brandSet.toList()..sort();

    if (mounted) {
      setState(() {
        _categories = categories;
        _brands = brands;
      });
    }
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  /// The non-empty, trimmed image URLs currently entered in the form.
  List<String> get _imageUrls => _imageUrlControllers
      .map((c) => c.text.trim())
      .where((url) => url.isNotEmpty)
      .toList();

  /// Live validation used to keep the Save button disabled until valid.
  bool get _isFormValid {
    final mrp = double.tryParse(_mrpController.text.trim());
    final price = double.tryParse(_priceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim());

    final category = (_selectedCategory ?? '').trim();
    // When "Other" is selected, the category selector exposes the typed
    // new-category value; validate min 2 / max 40 chars.
    final categoryValid = category.isNotEmpty &&
        category.length >= 2 &&
        category.length <= 40;

return categoryValid &&
        _nameController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _weightController.text.trim().isNotEmpty &&
        _skuController.text.trim().isNotEmpty &&
        mrp != null &&
        mrp > 0 &&
        price != null &&
        price > 0 &&
        stock != null &&
        stock >= 0 &&
        _imageUrls.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameTeluguController.dispose();
    _descriptionController.dispose();
    _descriptionTeluguController.dispose();
    _deliveryTimeController.dispose();
    _gstController.dispose();
    _mrpController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _weightController.dispose();
    _skuController.dispose();
    for (final c in _imageUrlControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addImageUrlField() {
    if (_imageUrlControllers.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Up to 5 image URLs are supported')),
      );
      return;
    }
    setState(() {
      final controller = TextEditingController();
      controller.addListener(_onFieldChanged);
      _imageUrlControllers.add(controller);
    });
  }

  void _removeImageUrlField(int index) {
    setState(() {
      _imageUrlControllers[index].removeListener(_onFieldChanged);
      _imageUrlControllers[index].dispose();
      _imageUrlControllers.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_isFormValid) {
      _formKey.currentState!.validate();
      setState(() {});
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final category = (_selectedCategory ?? '').trim();
    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product image URL'),
        ),
      );
      return;
    }

setState(() => _isSubmitting = true);

    final brand = (_selectedBrand ?? '').trim();
    final productsProvider = context.read<ProductsProvider>();

    final variant = VariantModel(
      id: '',
      weight: _weightController.text.trim(),
      mrp: double.tryParse(_mrpController.text.trim()) ?? 0,
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      offerPrice: double.tryParse(_priceController.text.trim()) ?? 0,
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      sku: _skuController.text.trim(),
      active: true,
    );

    final product = ProductModel(
      id: '',
      name: _nameController.text.trim(),
      nameTelugu: _nameTeluguController.text.trim(),
      brandId: '',
      brandName: brand,
      categoryId: '',
      categoryName: category,
      subCategoryId: '',
      subCategoryName: '',
      description: _descriptionController.text.trim(),
      descriptionTelugu: _descriptionTeluguController.text.trim(),
      deliveryTime: _deliveryTimeController.text.trim(),
      gst: double.tryParse(_gstController.text.trim()) ?? 0,
      images: _imageUrls,
      variants: [variant],
    );

    try {
      await _repo.addProduct(product);
      await productsProvider.loadProducts(force: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product Added Successfully')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/products',
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VKartAppBar(title: 'Add Product'),
      body: _isSubmitting
          ? const Center(child: VKartLoading(message: 'Adding product...'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 16),
                    VKartCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Basic Details'),
                          const SizedBox(height: 16),
                          VKartTextField(
                            label: 'Product Name (English) *',
                            controller: _nameController,
                            hint: 'e.g. Basmati Rice',
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Name is required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          VKartTextField(
                            label: 'Product Name (Telugu)',
                            controller: _nameTeluguController,
                            hint: 'e.g. బాస్మతి బియ్యం',
                          ),
                          const SizedBox(height: 16),
                          VKartTextField(
                            label: 'Description (English) *',
                            controller: _descriptionController,
                            hint: 'Short description',
                            maxLines: 3,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Description is required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          VKartTextField(
                            label: 'Description (Telugu)',
                            controller: _descriptionTeluguController,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    VKartCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Classification'),
                          const SizedBox(height: 16),
                          VKartCategorySelector(
                            categories: _categories,
                            onChanged: (v) =>
                                setState(() => _selectedCategory = v),
                          ),
                          const SizedBox(height: 16),
                          VKartBrandAutocomplete(
                            brands: _brands,
                            onChanged: (v) =>
                                setState(() => _selectedBrand = v),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: VKartTextField(
                                  label: 'Delivery Time',
                                  controller: _deliveryTimeController,
                                  hint: 'e.g. 30 mins',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: VKartTextField(
                                  label: 'GST (%)',
                                  controller: _gstController,
                                  hint: 'e.g. 5',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    VKartCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Pricing & Stock'),
                          const SizedBox(height: 16),
                          VKartTextField(
                            label: 'Weight / Size *',
                            controller: _weightController,
                            hint: 'e.g. 1 kg',
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Weight is required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: VKartTextField(
                                  label: 'MRP (₹) *',
                                  controller: _mrpController,
                                  prefixIcon: Icons.currency_rupee_rounded,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'),
                                    ),
                                  ],
                                  validator: (v) {
                                    final val = double.tryParse(
                                      (v ?? '').trim(),
                                    );
                                    if (val == null || val <= 0) {
                                      return 'Enter a valid MRP';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: VKartTextField(
                                  label: 'Price (₹) *',
                                  controller: _priceController,
                                  prefixIcon: Icons.currency_rupee_rounded,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'),
                                    ),
                                  ],
                                  validator: (v) {
                                    final val = double.tryParse(
                                      (v ?? '').trim(),
                                    );
                                    if (val == null || val <= 0) {
                                      return 'Enter a valid price';
                                    }
                                    return null;
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
                                  label: 'Stock *',
                                  controller: _stockController,
                                  prefixIcon: Icons.inventory_rounded,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (v) {
                                    final val = int.tryParse(
                                      (v ?? '').trim(),
                                    );
                                    if (val == null || val < 0) {
                                      return 'Enter valid stock';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: VKartTextField(
                                  label: 'SKU *',
                                  controller: _skuController,
                                  prefixIcon: Icons.qr_code_rounded,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'SKU is required'
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    VKartButton(
                      text: 'Add Product',
                      prefixIcon: Icons.add_box_rounded,
                      isLoading: _isSubmitting,
                      isDisabled: !_isFormValid,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Product Images *'),
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
