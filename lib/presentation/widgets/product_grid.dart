import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/product.dart';
import 'product_card.dart';

class ProductGrid extends StatefulWidget {
  final double maxCrossAxisExtent;
  final Function(Product) onProductSelected;
  final bool isScrollable;
  final EdgeInsets padding;
  final List<Product> products;

  const ProductGrid({
    super.key,
    this.maxCrossAxisExtent = 300,
    required this.onProductSelected,
    this.isScrollable = true,
    this.padding = const EdgeInsets.all(24),
    this.products = const [],
  });

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return Center(child: Text('catalog.empty'.tr()));
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: GridView.builder(
        controller: _scrollController,
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
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          return ProductCard(
            product: widget.products[index],
            onProductSelected: widget.onProductSelected,
          );
        },
      ),
    );
  }
}