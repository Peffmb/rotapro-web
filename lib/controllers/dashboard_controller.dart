import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rotago_web/repositories/entregadores_repository.dart';

class DashboardController extends ChangeNotifier {
  final EntregadoresRepository _repository;
  Timer? _timerSimulacao;
  bool _mostrarApenasOnline = false;

  bool get mostrarApenasOnline => _mostrarApenasOnline;

  DashboardController({EntregadoresRepository? repository})
      : _repository = repository ?? EntregadoresRepository();

  void toggleFiltroOnline(bool value) {
    _mostrarApenasOnline = value;
    notifyListeners();
  }

  // Acesso ao stream do repositório
  Stream get entregadoresStream => _mostrarApenasOnline
      ? _repository.getEntregadoresOnlineStream()
      : _repository.getEntregadoresStream();

  bool _isSimulacaoAtiva = false;
  bool get isSimulacaoAtiva => _isSimulacaoAtiva;

  // Inicia a simulação de movimento dos entregadores
  void iniciarSimulacao() {
    if (_isSimulacaoAtiva) return;
    
    _isSimulacaoAtiva = true;
    notifyListeners();
    
    _timerSimulacao = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final snapshot = await _repository.getCollectionSnapshot();
        final random = Random();

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['localizacao_atual'] == null) continue;

          double lat = data['localizacao_atual']['lat'];
          double lng = data['localizacao_atual']['lng'];
          
          // Movimento aleatório pequeno
          double moveLat = (random.nextDouble() - 0.5) * 0.0005;
          double moveLng = (random.nextDouble() - 0.5) * 0.0005;

          // Atualiza via repositório
          await _repository.updateSimulacao(doc.id, {
            'localizacao_atual': {'lat': lat + moveLat, 'lng': lng + moveLng},
            'status': random.nextInt(10) > 2 ? 'online' : 'ocupado',
          });
        }
      } catch (e) {
        debugPrint('Erro na simulação: $e');
      }
    });
  }

  void pararSimulacao() {
    _cancelarSimulacao();
  }
  
  void toggleSimulacao() {
    if (_isSimulacaoAtiva) {
      pararSimulacao();
    } else {
      iniciarSimulacao();
    }
  }

  void _cancelarSimulacao() {
    _timerSimulacao?.cancel();
    _timerSimulacao = null;
    _isSimulacaoAtiva = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelarSimulacao();
    super.dispose();
  }
}
