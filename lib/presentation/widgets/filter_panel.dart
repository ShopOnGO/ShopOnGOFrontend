import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/brand.dart';

class FilterPanel extends StatefulWidget {
  final Function(RangeValues range, int? brandId)? onApply;
  final List<Brand> brands;
  final int? initialBrandId;
  final RangeValues? initialRange;
  final double maxLimit;
  final bool isMobile; 

  const FilterPanel({
    super.key,
    this.onApply,
    this.brands = const [],
    this.initialBrandId,
    this.initialRange,
    this.maxLimit = 1000,
    this.isMobile = false,
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
    _initRange();
    _selectedBrandId = widget.initialBrandId;
  }

  void _initRange() {
    double start = widget.initialRange?.start ?? 0;
    double end = widget.initialRange?.end ?? widget.maxLimit;

    _currentRangeValues = RangeValues(
      start.clamp(0, widget.maxLimit),
      end.clamp(0, widget.maxLimit),
    );
  }

  @override
  void didUpdateWidget(FilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxLimit != widget.maxLimit ||
        oldWidget.initialRange != widget.initialRange) {
      setState(() {
        _initRange();
      });
    }
    if (oldWidget.initialBrandId != widget.initialBrandId) {
      _selectedBrandId = widget.initialBrandId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final double effectiveMax = widget.maxLimit > 0 ? widget.maxLimit : 100;

    return Container(
      decoration: widget.isMobile ? null : BoxDecoration(
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
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.isMobile) const SizedBox(height: 25),

            if (widget.isMobile) ...[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.onSecondaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'filter.price'.tr(),
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                Text(
                  '${_currentRangeValues.start.round()} - ${_currentRangeValues.end.round()} BYN',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: effectiveMax,
              divisions: effectiveMax > 1000 ? 100 : effectiveMax.round().clamp(1, 1000),
              activeColor: colorScheme.primary,
              labels: RangeLabels(
                '${_currentRangeValues.start.round()}',
                '${_currentRangeValues.end.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'filter.brands'.tr(),
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.isMobile ? 300 : 150),
              child: widget.brands.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'filter.loading_brands'.tr(),
                          style: TextStyle(color: colorScheme.onSecondaryContainer),
                        ),
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
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text('filter.apply'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}