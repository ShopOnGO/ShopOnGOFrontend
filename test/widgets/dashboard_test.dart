import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tailornado/app/dashboard_page.dart';
import 'package:tailornado/data/providers/auth_provider.dart';
import 'package:tailornado/data/providers/cart_provider.dart';
import 'package:tailornado/data/providers/liked_provider.dart';
import 'package:tailornado/data/providers/chat_provider.dart';
import 'package:tailornado/data/providers/view_history_provider.dart';
import 'package:tailornado/data/providers/product_provider.dart';

void main() {
  testWidgets('DashboardPage отображает название приложения', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => LikedProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => ViewHistoryProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
        ],
        child: MaterialApp(
          home: DashboardPage(toggleTheme: () {}),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tailornado'), findsOneWidget);
    expect(find.byIcon(Icons.brightness_6), findsOneWidget);
  });
}