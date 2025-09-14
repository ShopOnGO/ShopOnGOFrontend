import 'package:flutter/material.dart';
import 'left_card.dart';
import 'right_card.dart';

class InfoBlock extends StatelessWidget {
  final double spacing;
  final double leftCardHeight;
  final double rightCardHeight;
  final Color leftCardColor;
  final Color rightCardColor;

  const InfoBlock({
    super.key,
    this.spacing = 16,
    this.leftCardHeight = 150,
    this.rightCardHeight = 150,
    this.leftCardColor = Colors.black,
    this.rightCardColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LeftCard(height: leftCardHeight, color: leftCardColor),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: RightCard(height: rightCardHeight, color: rightCardColor),
        ),
      ],
    );
  }
}
