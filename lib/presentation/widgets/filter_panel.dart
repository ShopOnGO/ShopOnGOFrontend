import 'package:flutter/material.dart';

class FilterPanel extends StatefulWidget {
  final VoidCallback? onApply;

  const FilterPanel({
    super.key,
    this.onApply,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  RangeValues _currentRangeValues = const RangeValues(20, 150);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Text('Цена', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSecondaryContainer)),
            RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: 500,
              divisions: 25,
              activeColor: colorScheme.primary,
              inactiveColor: colorScheme.onSecondaryContainer.withValues(alpha: 0.3),
              labels: RangeLabels('${_currentRangeValues.start.round()} BYN', '${_currentRangeValues.end.round()} BYN'),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: widget.onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Применить'),
            ),
          ],
        ),
      ),
    );
  }
}