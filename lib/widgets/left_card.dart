import 'package:flutter/material.dart';

class LeftCard extends StatelessWidget {
  final double height;
  final Color color;
  final double borderRadius;
  final double bottomRectHeight;
  final double bottomRectRatio;
  final double bottomOffset;

  const LeftCard({
    super.key,
    this.height = 150,
    this.color = Colors.black,
    this.borderRadius = 20,
    this.bottomRectHeight = 40,
    this.bottomRectRatio = 0.5,
    this.bottomOffset = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: LeftCardClipper(
        borderRadius: borderRadius,
        bottomRectHeight: bottomRectHeight,
        bottomRectRatio: bottomRectRatio,
        bottomOffset: bottomOffset,
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

class LeftCardClipper extends CustomClipper<Path> {
  final double borderRadius;
  final double bottomRectHeight;
  final double bottomRectRatio;
  final double bottomOffset;

  LeftCardClipper({
    required this.borderRadius,
    required this.bottomRectHeight,
    required this.bottomRectRatio,
    required this.bottomOffset,
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

    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          size.height - bottomRectHeight - bottomOffset,
          bottomRectWidth,
          bottomRectHeight + bottomOffset + 5,
        ),
        Radius.circular(borderRadius),
      ),
    );

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
