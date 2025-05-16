import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'services/auth_service.dart';
import 'services/account_service.dart';
import 'services/transaction_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<AccountService>(
          create: (_) => AccountService(),
        ),
        Provider<TransactionService>(
          create: (_) => TransactionService(),
        ),
      ],
      child: MaterialApp(
        title: 'Blinq',
        theme: AppTheme.theme,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.splash,
      ),
    );
  }
}
