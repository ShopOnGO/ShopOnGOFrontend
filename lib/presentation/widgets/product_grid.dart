import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/services/product_service.dart';
import 'product_card.dart';

class ProductGrid extends StatefulWidget {
  final double maxCrossAxisExtent;
  final Function(Product) onProductSelected;
  final bool isScrollable;
  final EdgeInsets padding;
  final List<Product>? products;

  const ProductGrid({
    super.key,
    this.maxCrossAxisExtent = 300,
    required this.onProductSelected,
    this.isScrollable = true,
    this.padding = const EdgeInsets.all(24),
    this.products,
  });

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  late Future<List<Product>> _productsFuture;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    if (widget.products == null) {
      _productsFuture = _productService.fetchProducts();
    }
  }

  Widget _buildGrid(List<Product> products) {
    return GridView.builder(
      padding: widget.padding,
      shrinkWrap: !widget.isScrollable,
      physics: widget.isScrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: widget.maxCrossAxisExtent,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          onProductSelected: widget.onProductSelected,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products != null) {
      return _buildGrid(widget.products!);
    } else {
      return FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Товары не найдены'));
          }
          final products = snapshot.data!;
          return _buildGrid(products);
        },
      );
    }
  }
}
