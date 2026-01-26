import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rotago_web/services/auth_service.dart';
import 'package:rotago_web/widgets/cad_entregador_dialog.dart';
import 'package:rotago_web/screens/entregadores_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LatLng _centroInicial = const LatLng(-23.420999, -51.933056);
  Timer? _timerSimulacao;
  bool _mostrarApenasOnline = false;

  // Cores personalizadas para este arquivo
  final Color _corVermelho = const Color(0xFFD32F2F);
  final Color _corPreto = Colors.black;
  final Color _corBranco = Colors.white;

  @override
  void initState() {
    super.initState();
    _iniciarSimulacao();
  }

  @override
  void dispose() {
    _timerSimulacao?.cancel();
    super.dispose();
  }

  void _iniciarSimulacao() {
    _timerSimulacao = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final snapshot = await FirebaseFirestore.instance
          .collection('entregadores')
          .get();
      final random = Random();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['localizacao_atual'] == null) continue;
        double lat = data['localizacao_atual']['lat'];
        double lng = data['localizacao_atual']['lng'];
        double moveLat = (random.nextDouble() - 0.5) * 0.0005;
        double moveLng = (random.nextDouble() - 0.5) * 0.0005;
        doc.reference.update({
          'localizacao_atual': {'lat': lat + moveLat, 'lng': lng + moveLng},
          'status': random.nextInt(10) > 2 ? 'online' : 'ocupado',
        });
      }
    });
  }

  void _mostrarDetalhesMoto(Map<String, dynamic> dados) {
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
                    // Avatar vermelho com ícone branco
                    backgroundColor: _corVermelho,
                    child: Icon(Icons.person, size: 30, color: _corBranco),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dados['nome'] ?? 'Entregador',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Placa: ${dados['placa']}",
                        style: const TextStyle(color: Colors.grey),
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
                  ),
                  _infoCard(
                    Icons.speed,
                    "Velocidade",
                    "${Random().nextInt(40) + 10} km/h",
                  ),
                  _infoCard(
                    Icons.shopping_bag,
                    "Entregas",
                    "${Random().nextInt(10)} hoje",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard(IconData icon, String titulo, String valor) {
    return Column(
      children: [
        Icon(icon, color: _corPreto), // Ícones pretos
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("RotaGo - Monitoramento"),
        // As cores já vêm do tema global, não precisa definir aqui
        actions: [
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
                color: _corVermelho,
              ), // Cabeçalho Vermelho
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delivery_dining, size: 50, color: _corBranco),
                  SizedBox(height: 10),
                  Text(
                    "Menu RotaGo",
                    style: TextStyle(color: _corBranco, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.map, color: _corPreto), // Ícone preto
              title: const Text("Mapa em Tempo Real"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.people, color: _corPreto), // Ícone preto
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
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('entregadores')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  var docs = snapshot.data!.docs;
                  if (_mostrarApenasOnline) {
                    docs = docs.where((d) => d['status'] == 'online').toList();
                  }
                  List<Marker> marcadores = docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (!data.containsKey('localizacao_atual'))
                      return const Marker(
                        point: LatLng(0, 0),
                        child: SizedBox(),
                      );
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
                                color: _corBranco,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: Colors.black45,
                                  ),
                                ],
                                // Borda Vermelha
                                border: Border.all(
                                  color: _corVermelho,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 18,
                                // Fundo Vermelho com ícone Branco
                                backgroundColor: _corVermelho,
                                child: Icon(
                                  Icons.two_wheeler,
                                  color: _corBranco,
                                  size: 20,
                                ),
                              ),
                            ),
                            // Seta Vermelha
                            Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                              color: _corVermelho,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _corBranco.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                nome,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _corPreto,
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
              ),
            ],
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _corBranco,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(blurRadius: 5, color: Colors.black26),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    "Apenas Online",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _corPreto,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _mostrarApenasOnline,
                    // Cor do switch quando ativo (Vermelho)
                    activeColor: _corVermelho,
                    onChanged: (val) {
                      setState(() {
                        _mostrarApenasOnline = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // O botão flutuante já pega a cor do tema global
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
