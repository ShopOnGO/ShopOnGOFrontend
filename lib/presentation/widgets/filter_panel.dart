import 'package:flutter/material.dart';
import '../../data/models/brand.dart';

class FilterPanel extends StatefulWidget {
  final Function(RangeValues range, int? brandId)? onApply;
  final List<Brand> brands;
  final int? initialBrandId;
  final RangeValues? initialRange;

  const FilterPanel({
    super.key,
    this.onApply,
    this.brands = const [],
    this.initialBrandId,
    this.initialRange,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late RangeValues _currentRangeValues;
  int? _selectedBrandId;

  @override
  void initState() {
    super.initState();
    _currentRangeValues = widget.initialRange ?? const RangeValues(0, 500);
    _selectedBrandId = widget.initialBrandId;
  }

  @override
  void didUpdateWidget(FilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialBrandId != widget.initialBrandId) {
      _selectedBrandId = widget.initialBrandId;
    }
    if (oldWidget.initialRange != widget.initialRange && widget.initialRange != null) {
      _currentRangeValues = widget.initialRange!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Цена',
                    style: textTheme.titleMedium
                        ?.copyWith(color: colorScheme.onSecondaryContainer)),
                Text(
                  '${_currentRangeValues.start.round()} - ${_currentRangeValues.end.round()} BYN',
                  style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: 500,
              divisions: 50,
              activeColor: colorScheme.primary,
              labels: RangeLabels('${_currentRangeValues.start.round()}',
                  '${_currentRangeValues.end.round()}'),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Бренды',
                style: textTheme.titleMedium
                    ?.copyWith(color: colorScheme.onSecondaryContainer)),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: widget.brands.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Загрузка брендов...'),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: widget.brands.map((brand) {
                          final isSelected = _selectedBrandId == brand.id;
                          return ChoiceChip(
                            label: Text(brand.name),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedBrandId = selected ? brand.id : null;
                              });
                            },
                            selectedColor: colorScheme.primary,
                            backgroundColor: theme.cardColor,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                widget.onApply?.call(_currentRangeValues, _selectedBrandId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
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