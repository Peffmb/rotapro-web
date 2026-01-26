import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rotago_web/screens/dashboard_screen.dart';
import 'package:rotago_web/screens/login_screen.dart';
import 'package:rotago_web/firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase dados
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  runApp(const RotaGoApp());
}

class RotaGoApp extends StatelessWidget {
  const RotaGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definindo a paleta de cores da Rota Lanches
    const corPrimaria = Color(0xFFD32F2F); // Vermelho vivo
    const corSecundaria = Colors.black; // Preto
    const corFundo = Colors.white; // Branco

    return MaterialApp(
      title: 'RotaGo - Rota Lanches', // Atualizei o título
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define o Vermelho como cor principal
        primaryColor: corPrimaria,
        // Define o esquema de cores para componentes (botões, switches, etc.)
        colorScheme: ColorScheme.fromSeed(
          seedColor: corPrimaria,
          primary: corPrimaria,
          secondary: corSecundaria,
          background: corFundo,
        ),
        // Cor de fundo padrão das telas
        scaffoldBackgroundColor: corFundo,
        // Estilo da AppBar (Barra superior)
        appBarTheme: const AppBarTheme(
          backgroundColor: corPrimaria,
          foregroundColor: corFundo, // Texto e ícones brancos
          elevation: 4, // Sombra para destaque
        ),
        // Estilo dos Botões Elevados (como o de "Salvar")
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: corPrimaria,
            foregroundColor: corFundo, // Texto branco
          ),
        ),
        // Estilo dos Botões Flutuantes (o "+" no mapa)
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: corPrimaria,
          foregroundColor: corFundo,
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const DashboardScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
