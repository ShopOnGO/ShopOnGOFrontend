import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FaqPage extends StatelessWidget {
  final VoidCallback onClose;

  const FaqPage({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return _buildWrapper(
      context,
      title: "faq.title".tr(),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        children: [
          ExpansionTile(
            title: Text("faq.example_q".tr()),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("faq.example_a".tr()),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWrapper(BuildContext context, {required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 6),
                ),
                child: Card(
                  margin: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(title, style: theme.textTheme.headlineSmall),
                      ),
                      const Divider(height: 1),
                      Flexible(child: child),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -15,
                right: -15,
                child: FloatingActionButton.small(
                  onPressed: onClose,
                  backgroundColor: theme.colorScheme.error,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}