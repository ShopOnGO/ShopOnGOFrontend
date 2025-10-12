import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text("Баланс", style: textTheme.headlineSmall)),
      ),
    );
  }
}
