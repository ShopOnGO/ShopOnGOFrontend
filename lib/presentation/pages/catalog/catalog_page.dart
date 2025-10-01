import 'package:flutter/material.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Каталог",
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}
