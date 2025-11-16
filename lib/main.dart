import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:provider/provider.dart';
import 'data/providers/cart_provider.dart';
import 'data/providers/view_history_provider.dart';
import 'data/providers/liked_provider.dart';
import 'data/providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ViewHistoryProvider()),
        ChangeNotifierProvider(create: (context) => LikedProvider()),
      ],
      child: const App(),
    ),
  );
}
