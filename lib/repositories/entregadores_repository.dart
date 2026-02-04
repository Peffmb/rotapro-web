import 'package:cloud_firestore/cloud_firestore.dart';

class EntregadoresRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retorna um Stream com a lista de todos os entregadores em tempo real
  Stream<QuerySnapshot> getEntregadoresStream() {
    return _firestore.collection('entregadores').snapshots();
  }

  /// Retorna um Stream filtrado apenas por entregadores online
  Stream<QuerySnapshot> getEntregadoresOnlineStream() {
    return _firestore
        .collection('entregadores')
        .where('status', isEqualTo: 'online')
        .snapshots();
  }

  /// Busca todos os documentos (uso único)
  Future<List<Map<String, dynamic>>> getAll() async {
    final snapshot = await _firestore.collection('entregadores').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Atualiza a localização e status de um entregador (usado na simulação)
  Future<void> updateSimulacao(String id, Map<String, dynamic> data) async {
    await _firestore.collection('entregadores').doc(id).update(data);
  }

  /// Retorna o snapshot da coleção para acesso aos Docs e IDs (necessário para simulação)
  Future<QuerySnapshot> getCollectionSnapshot() {
    return _firestore.collection('entregadores').get();
  }

  /// Adiciona um novo entregador
  Future<void> addEntregador(Map<String, dynamic> data) async {
    // Garante que a data de criação seja gerada pelo servidor
    final dadosParaSalvar = Map<String, dynamic>.from(data);
    dadosParaSalvar['criado_em'] = FieldValue.serverTimestamp();
    
    await _firestore.collection('entregadores').add(dadosParaSalvar);
  }

  /// Remove um entregador pelo ID
  Future<void> deleteEntregador(String id) async {
    await _firestore.collection('entregadores').doc(id).delete();
  }
}
