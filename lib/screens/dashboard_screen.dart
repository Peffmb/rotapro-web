import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rotago_web/controllers/dashboard_controller.dart';
import 'package:rotago_web/services/auth_service.dart';
import 'package:rotago_web/widgets/cad_entregador_dialog.dart';
import 'package:rotago_web/screens/entregadores_screen.dart';
import 'package:rotago_web/widgets/blinking_moto_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LatLng _centroInicial = const LatLng(-23.420999, -51.933056);
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.iniciarSimulacao();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _mostrarDetalhesMoto(Map<String, dynamic> dados) {
    if (!mounted) return;
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.primary,
                    child: Icon(Icons.person, size: 30, color: colorScheme.onPrimary),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dados['nome'] ?? 'Entregador',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Placa: ${dados['placa']}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "ONLINE",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoCard(
                    Icons.battery_charging_full,
                    "Bateria",
                    "${Random().nextInt(20) + 80}%",
                    colorScheme.onSurface,
                  ),
                  _infoCard(
                    Icons.speed,
                    "Velocidade",
                    "${Random().nextInt(40) + 10} km/h",
                    colorScheme.onSurface,
                  ),
                  _infoCard(
                    Icons.shopping_bag,
                    "Entregas",
                    "${Random().nextInt(10)} hoje",
                    colorScheme.onSurface,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard(IconData icon, String titulo, String valor, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(height: 5),
        Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Acesso ao tema global (definido no main.dart)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("RotaGo - Monitoramento"),
        actions: [
          // Botão de Simulação (Moto Piscando)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return BlinkingMotoButton(
                isSimulating: _controller.isSimulacaoAtiva,
                onPressed: _controller.toggleSimulacao,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delivery_dining, size: 50, color: colorScheme.onPrimary),
                  const SizedBox(height: 10),
                  Text(
                    "Menu RotaGo",
                    style: TextStyle(color: colorScheme.onPrimary, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.map, color: colorScheme.onSurface),
              title: const Text("Mapa em Tempo Real"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.people, color: colorScheme.onSurface),
              title: const Text("Gerenciar Entregadores"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EntregadoresScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _centroInicial,
              initialZoom: 14.5,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.rotago.app',
                tileProvider: NetworkTileProvider(),
                panBuffer: 1,
              ),
              // Usamos AnimatedBuilder para reconstruir apenas quando o Controller notificar mudanças
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: _controller.entregadoresStream as Stream<QuerySnapshot>,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      
                      final docs = snapshot.data!.docs;
                      // A filtragem agora acontece no nível da query no controller/repository
                      // mas se estivermos usando o stream geral, o controller troca a source.
                      
                      List<Marker> marcadores = docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        if (!data.containsKey('localizacao_atual')) {
                           return const Marker(
                            point: LatLng(0, 0),
                            child: SizedBox(),
                          );
                        }
                        
                        final lat = data['localizacao_atual']['lat'];
                        final lng = data['localizacao_atual']['lng'];
                        final nome = data['nome'] ?? 'Entregador';
                        
                        return Marker(
                          point: LatLng(lat, lng),
                          width: 100,
                          height: 100,
                          child: GestureDetector(
                            onTap: () => _mostrarDetalhesMoto(data),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 4,
                                        color: Colors.black45,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: colorScheme.primary,
                                    child: Icon(
                                      Icons.two_wheeler,
                                      color: colorScheme.onPrimary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    nome,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList();
                      return MarkerLayer(markers: marcadores);
                    },
                  );
                },
              ),
            ],
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(blurRadius: 5, color: Colors.black26),
                ],
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Row(
                    children: [
                      Text(
                        "Apenas Online",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _controller.mostrarApenasOnline,
                        activeColor: colorScheme.primary,
                        onChanged: _controller.toggleFiltroOnline,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const NovoEntregadorDialog(),
          );
        },
        label: const Text("Novo Entregador"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
