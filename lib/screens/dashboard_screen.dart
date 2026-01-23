import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Biblioteca do Mapa
import 'package:latlong2/latlong.dart'; // Utilitário de Coordenadas
import 'package:rotago_web/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Coordenadas iniciais (Centro de Maringá - PR)
  final LatLng _centroInicial = const LatLng(-23.420999, -51.933056);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RotaGo - Monitoramento"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: "Sair",
            onPressed: () {
              AuthService().logout();
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _centroInicial, // Centraliza em Maringá
          initialZoom: 14.0, // Zoom inicial
        ),
        children: [
          TileLayer(
            // Carrega as imagens do mapa (OpenStreetMap - Gratuito)
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.rotago.app',
          ),
          // Camada onde colocaremos as motos (Marcadores) depois
          const MarkerLayer(markers: []),
        ],
      ),
      // Botão flutuante para adicionar entregadores
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print("Botão clicado: Adicionar Entregador");
        },
        label: const Text("Novo Entregador"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }
}
