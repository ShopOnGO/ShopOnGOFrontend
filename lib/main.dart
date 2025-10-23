import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:provider/provider.dart';
import 'data/providers/cart_provider.dart';
import 'data/providers/view_history_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ViewHistoryProvider()),
      ],
      child: const App(),
    ),
  );
}
