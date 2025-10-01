import 'package:flutter/material.dart';

class LikedPage extends StatelessWidget {
  const LikedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Избранное",
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}
