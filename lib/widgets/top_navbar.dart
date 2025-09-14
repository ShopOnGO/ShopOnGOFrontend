import 'package:flutter/material.dart';

class TopNavbar extends StatelessWidget {
  final int itemCount;
  final double itemWidth;
  final double overlap;
  final double height;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets margin;

  const TopNavbar({
    super.key,
    this.itemCount = 4,
    this.itemWidth = 100,
    this.overlap = 20,
    this.height = 40,
    this.color = Colors.grey,
    this.borderColor = Colors.white,
    this.borderWidth = 7,
    this.borderRadius = 20,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: SizedBox(
        height: height,
        child: Center(
          child: SizedBox(
            width: itemCount * itemWidth - (itemCount - 1) * overlap,
            height: height,
            child: Stack(
              children: List.generate(itemCount, (index) {
                int reversedIndex = itemCount - 1 - index;
                return Positioned(
                  left: reversedIndex * itemWidth - reversedIndex * overlap,
                  child: Container(
                    height: height,
                    width: itemWidth,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: borderColor,
                        width: borderWidth,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
