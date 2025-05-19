import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart'; // Certifique-se de gerar este arquivo com flutterfire

import 'lib/core/services/auth_service.dart';
import '/DisplayProfiles/';
import 'controllers/transaction_controller.dart';

void main() async {
  // Garantir que os widgets do Flutter estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configurar injeção de dependências com GetX
  Get.put(AuthService());
  Get.put(TransactionService());
  Get.put(TransactionController());

  runApp(const BlinqApp());
}

class BlinqApp extends StatelessWidget {
  const BlinqApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Blinq Bank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Defina suas rotas aqui
      initialRoute: '/login',
      getPages: [
        // Adicione suas rotas aqui quando criar as telas
        // GetPage(name: '/login', page: () => LoginScreen()),
        // GetPage(name: '/home', page: () => HomeScreen()),
      ],
    );
  }
}