import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
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
      logger.d("AddProduct: Image selected: $_selectedFileName");
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFileBytes == null || _selectedFileName == null) {
      NotificationHelper.show(
        context,
        message: "Выберите изображение товара",
        isError: true,
      );
      return;
    }

    setState(() => _isProcessing = true);
    final auth = context.read<AuthProvider>();

    try {
      logger.i("AddProduct: Step 1 - Uploading image...");
      final String? fullImageUrl = await _productService.uploadImage(
        _selectedFileBytes!,
        _selectedFileName!,
        auth.token!,
      );

      if (fullImageUrl == null) {
        throw Exception("Не удалось получить URL загруженного изображения");
      }

      logger.i("AddProduct: Image uploaded. URL: $fullImageUrl");

      final productData = {
        "name": _nameController.text.trim(),
        "description": _descController.text.trim(),
        "material": _materialController.text.trim(),
        "is_active": true,
        "category_id": 5,
        "brand_id": _selectedBrandId ?? 2,
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
          },
        ],
      };

      logger.d("AddProduct: Sending Final Payload: ${jsonEncode(productData)}");

      final success = await _productService.createProduct(
        productData,
        auth.token!,
      );

      if (success) {
        if (!mounted) return;
        NotificationHelper.show(context, message: "Товар успешно добавлен!");
        Navigator.of(context).pop();
      } else {
        throw Exception("Ошибка сервера при сохранении товара");
      }
    } catch (e) {
      logger.e("AddProduct Error", error: e);
      if (!mounted) return;
      NotificationHelper.show(
        context,
        message: e.toString().replaceAll("Exception: ", ""),
        isError: true,
      );
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
                        Text(
                          "Добавить новый товар",
                          style: theme.textTheme.headlineSmall,
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
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
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: _selectedFileBytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        _selectedFileBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 40,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Фото товара",
                                          textAlign: TextAlign.center,
                                        ),
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
                                decoration: _buildDecoration(
                                  "Название",
                                  Icons.shopping_bag_outlined,
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? "Введите название" : null,
                              ),
                              const SizedBox(height: 16),

                              _isLoadingBrands
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : DropdownButtonFormField<int>(
                                      initialValue: _selectedBrandId,
                                      isExpanded: true,
                                      decoration: _buildDecoration(
                                        "Бренд",
                                        Icons.business_outlined,
                                      ),
                                      items: _brands
                                          .map(
                                            (b) => DropdownMenuItem(
                                              value: b.id,
                                              child: Text(b.name),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) => setState(
                                        () => _selectedBrandId = val,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      "Характеристики и Вариант",
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _materialController,
                            decoration: _buildDecoration(
                              "Материал",
                              Icons.layers_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _skuController,
                            decoration: _buildDecoration(
                              "Артикул (SKU)",
                              Icons.tag,
                            ),
                            validator: (v) => v!.isEmpty ? "Обязательно" : null,
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
                            decoration: _buildDecoration(
                              "Цена (BYN)",
                              Icons.payments_outlined,
                            ),
                            validator: (v) =>
                                v!.isEmpty ? "Укажите цену" : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: _buildDecoration(
                              "Остаток (шт)",
                              Icons.inventory_2_outlined,
                            ),
                            validator: (v) =>
                                v!.isEmpty ? "Укажите кол-во" : null,
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
                            decoration: _buildDecoration(
                              "Цвет",
                              Icons.palette_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _sizeController,
                            decoration: _buildDecoration(
                              "Размер",
                              Icons.straighten_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _dimensionsController,
                      decoration: _buildDecoration(
                        "Габариты упаковки",
                        Icons.aspect_ratio_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: _buildDecoration(
                        "Описание товара",
                        Icons.description_outlined,
                      ),
                      validator: (v) => v!.isEmpty ? "Введите описание" : null,
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _isProcessing
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: const Text("Отмена"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isProcessing ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
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
                              : const Text("СОЗДАТЬ ТОВАР"),
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
