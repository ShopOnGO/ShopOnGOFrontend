import 'package:flutter/material.dart';

class OrderSummaryCard extends StatelessWidget {
  final double totalAmount;

  const OrderSummaryCard({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final Color panelColor = theme.colorScheme.secondaryContainer;
    final Color borderColor = theme.scaffoldBackgroundColor;
    const double borderWidth = 6.0;
    const double borderRadius = 22.0;

    return Container(
      padding: const EdgeInsets.all(borderWidth + 4),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    "ИТОГ: ${totalAmount.toStringAsFixed(0)} BYN",
                    style: textTheme.headlineSmall,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: TextField(
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: "Уточнения...",
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  elevation: 12,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("ЗАКАЗАТЬ", style: textTheme.titleMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}