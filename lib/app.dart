import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/sale_repository.dart';
import 'data/repositories/seller_repository.dart';
import 'providers/app_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/history_provider.dart';
import 'providers/sales_provider.dart';
import 'features/main/main_screen.dart';

class MaveApp extends StatelessWidget {
  const MaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseHelper();
    final productRepo = ProductRepository(db);
    final sellerRepo = SellerRepository(db);
    final saleRepo = SaleRepository(db);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider(sellerRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => SalesProvider(productRepo, saleRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(saleRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => AnalyticsProvider(saleRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(productRepo),
        ),
      ],
      child: Consumer<AppProvider>(
        builder: (context, app, _) {
          return MaterialApp(
            title: 'MAVE Sales',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: app.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ru', 'RU'),
              Locale('en', 'US'),
            ],
            locale: const Locale('ru', 'RU'),
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
