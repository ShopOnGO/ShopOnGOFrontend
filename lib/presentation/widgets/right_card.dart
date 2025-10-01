import 'package:flutter/material.dart';

class RightCard extends StatelessWidget {
  final double height;
  final Color color;
  final double borderRadius;
  final double bottomRectHeight;
  final double bottomRectRatio;

  const RightCard({
    super.key,
    this.height = 150,
    this.color = Colors.grey,
    this.borderRadius = 20,
    this.bottomRectHeight = 40,
    this.bottomRectRatio = 0.33,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: RightCardClipper(
        borderRadius: borderRadius,
        bottomRectHeight: bottomRectHeight,
        bottomRectRatio: bottomRectRatio,
      ),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class RightCardClipper extends CustomClipper<Path> {
  final double borderRadius;
  final double bottomRectHeight;
  final double bottomRectRatio;

  RightCardClipper({
    required this.borderRadius,
    required this.bottomRectHeight,
    required this.bottomRectRatio,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final bottomRectWidth = size.width * bottomRectRatio;

    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height - bottomRectHeight / 2),
        Radius.circular(borderRadius),
      ),
    );

    final bottomRectLeft = (size.width - bottomRectWidth) / 2;
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bottomRectLeft,
          size.height - bottomRectHeight,
          bottomRectWidth,
          bottomRectHeight,
        ),
        Radius.circular(borderRadius),
      ),
    );

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
