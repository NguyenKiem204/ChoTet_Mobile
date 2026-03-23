import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chotet/data/api_client.dart';
import 'package:chotet/data/services/auth_service.dart';
import 'package:chotet/data/services/price_book_service.dart';
import 'package:chotet/data/services/shopping_service.dart';
import 'package:chotet/viewmodels/auth_viewmodel.dart';
import 'package:chotet/themes/design_system.dart';
import 'package:chotet/viewmodels/home_viewmodel.dart';
import 'package:chotet/viewmodels/comparison_viewmodel.dart';
import 'package:chotet/views/main_shell.dart';
import 'package:chotet/views/auth/login_page.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  
  final apiClient = ApiClient();
  final authService = AuthService(apiClient);
  final priceBookService = PriceBookService(apiClient);
  final shoppingService = ShoppingService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: shoppingService),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService, apiClient)),
        ChangeNotifierProvider(create: (_) => ComparisonViewModel(priceBookService)),
        ChangeNotifierProxyProvider<AuthViewModel, HomeViewModel>(
          create: (context) => HomeViewModel(
            Provider.of<ShoppingService>(context, listen: false),
            Provider.of<AuthViewModel>(context, listen: false),
          ),
          update: (context, auth, home) => home ?? HomeViewModel(
            Provider.of<ShoppingService>(context, listen: false),
            auth,
          ),
        ),
      ],
      child: const ChoTetApp(),
    ),
  );
}

class ChoTetApp extends StatelessWidget {
  const ChoTetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChoTet',
      debugShowCheckedModeBanner: false,
      theme: AppDesignSystem.lightTheme,
      darkTheme: AppDesignSystem.darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer<AuthViewModel>(
        builder: (context, auth, _) {
          if (auth.isLoading && !auth.isAuthenticated) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.tetRed),
              ),
            );
          }

          if (auth.isAuthenticated) {
            return const MainShell();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
