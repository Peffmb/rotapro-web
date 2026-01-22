import 'package:flutter/material.dart';
import 'package:rotago_web/services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RotaGo - Painel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Botão para deslogar
              AuthService().logout();
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 80, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text("Bem-vindo ao Sistema!", style: TextStyle(fontSize: 24)),
            Text("Em breve: Mapas e Entregadores aqui."),
          ],
        ),
      ),
    );
  }
}
