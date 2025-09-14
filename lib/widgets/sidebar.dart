import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int itemCount;
  final double width;
  final Color backgroundColor;
  final Color iconColor;
  final double spacing;
  final double radius;

  const Sidebar({
    super.key,
    this.itemCount = 6,
    this.width = 70,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.grey,
    this.spacing = 12,
    this.radius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: backgroundColor,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.all(spacing),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
