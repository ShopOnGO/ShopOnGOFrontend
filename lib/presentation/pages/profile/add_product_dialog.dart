import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/brand.dart';
import '../../widgets/custom_notification.dart';
import '../../../core/utils/app_logger.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _materialController = TextEditingController(text: "хлопок");

  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _colorController = TextEditingController(text: "Черный");
  final _sizeController = TextEditingController(text: "M");
  final _dimensionsController = TextEditingController(text: "10x10x10 см");

  List<Brand> _brands = [];
  int? _selectedBrandId;

  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  bool _isProcessing = false;
  bool _isLoadingBrands = true;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await _productService.getAllBrands();
      setState(() {
        _brands = brands;
        if (_brands.isNotEmpty) {
          _selectedBrandId = _brands.first.id;
        }
        _isLoadingBrands = false;
      });
    } catch (e) {
      logger.e("AddProduct: Failed to load brands", error: e);
      setState(() => _isLoadingBrands = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _materialController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _dimensionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _selectedFileBytes = result.files.first.bytes;
        _selectedFileName = result.files.first.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFileBytes == null || _selectedFileName == null) {
      NotificationHelper.show(context, message: "add_product.err_no_image".tr(), isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    final auth = context.read<AuthProvider>();

    try {
      final String? fullImageUrl = await _productService.uploadImage(
        _selectedFileBytes!,
        _selectedFileName!,
        auth.token!,
      );

      if (fullImageUrl == null) {
        throw Exception("add_product.err_image_upload".tr());
      }

      final productData = {
        "name": _nameController.text.trim(),
        "description": _descController.text.trim(),
        "material": _materialController.text.trim(),
        "is_active": true,
        "category_id": 5, 
        "brand_id": _selectedBrandId ?? 1,
        "image_keys": [], 
        "video_keys": [],
        "variants": [
          {
            "sku": _skuController.text.trim(),
            "price": double.tryParse(_priceController.text) ?? 0.0,
            "discount": 0.0,
            "sizes": _sizeController.text.trim(),
            "colors": _colorController.text.trim(),
            "stock": int.tryParse(_stockController.text) ?? 0,
            "barcode": "1000000000027",
            "is_active": true,
            "images": [fullImageUrl],
            "min_order": 1,
            "dimensions": _dimensionsController.text.trim(),
          }
        ]
      };

      final success = await _productService.createProduct(productData, auth.token!);

      if (success) {
        if (!mounted) return;
        NotificationHelper.show(context, message: "add_product.success".tr());
        Navigator.of(context).pop();
      } else {
        throw Exception("auth.err_server".tr());
      }
    } catch (e) {
      if (!mounted) return;
      NotificationHelper.show(context, message: e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  InputDecoration _buildDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 850),
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("add_product.title".tr(), style: theme.textTheme.headlineSmall),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: _isProcessing ? null : _pickImage,
                            child: Container(
                              height: 160,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: _selectedFileBytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(_selectedFileBytes!, fit: BoxFit.cover),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add_a_photo_outlined, size: 40),
                                        const SizedBox(height: 8),
                                        Text("add_product.photo_placeholder".tr(), textAlign: TextAlign.center),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: _buildDecoration("add_product.name".tr(), Icons.shopping_bag_outlined),
                                validator: (v) => v!.isEmpty ? "add_product.err_name".tr() : null,
                              ),
                              const SizedBox(height: 16),
                              
                              _isLoadingBrands 
                                ? const Center(child: CircularProgressIndicator())
                                : DropdownButtonFormField<int>(
                                    initialValue: _selectedBrandId,
                                    isExpanded: true,
                                    decoration: _buildDecoration("add_product.brand".tr(), Icons.business_outlined),
                                    items: _brands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                                    onChanged: (val) => setState(() => _selectedBrandId = val),
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Text("profile.personal_info".tr(), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _materialController,
                            decoration: _buildDecoration("add_product.material".tr(), Icons.layers_outlined),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _skuController,
                            decoration: _buildDecoration("add_product.sku".tr(), Icons.tag),
                            validator: (v) => v!.isEmpty ? "add_product.err_required".tr() : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: _buildDecoration("add_product.price".tr(args: ['common.currency'.tr()]), Icons.payments_outlined),
                            validator: (v) => v!.isEmpty ? "add_product.err_price".tr() : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: _buildDecoration("add_product.stock".tr(), Icons.inventory_2_outlined),
                            validator: (v) => v!.isEmpty ? "add_product.err_stock".tr() : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _colorController,
                            decoration: _buildDecoration("add_product.color".tr(), Icons.palette_outlined),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _sizeController,
                            decoration: _buildDecoration("add_product.size".tr(), Icons.straighten_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _dimensionsController,
                      decoration: _buildDecoration("add_product.dimensions".tr(), Icons.aspect_ratio_outlined),
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: _buildDecoration("add_product.description".tr(), Icons.description_outlined),
                      validator: (v) => v!.isEmpty ? "add_product.err_desc".tr() : null,
                    ),
                    const SizedBox(height: 32),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _isProcessing ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                          child: Text("add_product.btn_cancel".tr()),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isProcessing ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          ),
                          child: _isProcessing
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text("add_product.btn_create".tr()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}