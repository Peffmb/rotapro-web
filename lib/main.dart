import 'package:flutter/material.dart';

void main() {
  runApp(const RotaGoApp());
}

class RotaGoApp extends StatelessWidget {
  const RotaGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RotaGo - Gestão de Entregas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Vamos definir a cor principal como um Azul Tecnológico ou Laranja Entrega
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text("RotaGo - Iniciando o Sistema...")),
      ),
    );
  }
}
