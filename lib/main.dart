import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app/app.dart';
import 'package:provider/provider.dart';
import 'data/providers/product_provider.dart';
import 'data/providers/cart_provider.dart';
import 'data/providers/view_history_provider.dart';
import 'data/providers/chat_provider.dart';
import 'data/providers/liked_provider.dart';
import 'data/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ru'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      startLocale: const Locale('ru'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => CartProvider()),
          ChangeNotifierProvider(create: (context) => ProductProvider()),
          ChangeNotifierProvider(create: (context) => ViewHistoryProvider()),
          ChangeNotifierProvider(create: (context) => LikedProvider()),
          ChangeNotifierProvider(create: (context) => ChatProvider()),
        ],
        child: const App(),
      ),
    ),
  );
}
