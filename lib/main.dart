import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/tatito_theme.dart';
import 'features/addresses/providers/address_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/catalog/providers/catalog_provider.dart';
import 'features/home/providers/food_preference_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/orders/providers/orders_provider.dart';
import 'features/reviews/providers/review_provider.dart';
import 'features/wishlist/providers/wishlist_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TatitoCustomerApp());
}

class TatitoCustomerApp extends StatelessWidget {
  const TatitoCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodPreferenceProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(
          create: (context) => OrdersProvider()
            ..attachCatalog(context.read<CatalogProvider>())
            ..attachNotifications(context.read<NotificationProvider>()),
        ),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        title: 'Tatito Foods',
        debugShowCheckedModeBanner: false,
        theme: TatitoTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
