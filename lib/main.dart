import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rotago_web/screens/dashboard_screen.dart';
import 'package:rotago_web/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- COLE SUAS CHAVES DO FIREBASE AQUI NOVAMENTE ---
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB4rxdoOiF1lPkhXVXOGfHaY9GFb5SOYu4",
      appId: "1:213019577977:web:5e04045936665f8e220ea8",
      messagingSenderId: "213019577977",
      projectId: "rotago-19a68",
      authDomain: "rotago-19a68.firebaseapp.com",
      storageBucket: "rotago-19a68.appspot.com",
    ),
  );

  runApp(const RotaGoApp());
}

class RotaGoApp extends StatelessWidget {
  const RotaGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RotaGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      // O StreamBuilder é o "Porteiro"
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Se estiver carregando, mostra rodinha
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. Se tiver usuário logado -> Manda para o Mapa (Dashboard)
          if (snapshot.hasData) {
            return const DashboardScreen();
          }

          // 3. Se não tiver ninguém -> Manda para o Login
          return const LoginScreen();
        },
      ),
    );
  }
}
