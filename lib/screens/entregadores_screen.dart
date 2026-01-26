import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class EntregadoresScreen extends StatelessWidget {
  const EntregadoresScreen({super.key});

  // Função para mostrar o alerta e excluir
  void _confirmarExclusao(BuildContext context, String docId, String nome) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Entregador?"),
        content: Text(
          "Tem certeza que deseja remover o entregador '$nome' do sistema? Essa ação não pode ser desfeita.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Fecha sem fazer nada
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // 1. Apaga do Firebase
              await FirebaseFirestore.instance
                  .collection('entregadores')
                  .doc(docId)
                  .delete();

              // 2. Fecha o alerta
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Entregador excluído com sucesso!"),
                  ),
                );
              }
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cores locais
    final Color corVermelho = Theme.of(context).primaryColor;
    const Color corPreto = Colors.black;
    const Color corBranco = Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciar Entregadores")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('entregadores')
            .orderBy('criado_em', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Erro ao carregar dados."));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final dados = snapshot.data!.docs;

          if (dados.isEmpty)
            return const Center(child: Text("Nenhum entregador cadastrado."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dados.length,
            itemBuilder: (context, index) {
              // Pegamos os dados e TAMBÉM o ID do documento para poder excluir
              final docId = dados[index].id;
              final entregador = dados[index].data() as Map<String, dynamic>;

              final String nome = entregador['nome'] ?? 'Sem nome';
              final String cpf = entregador['cpf'] ?? '---';
              final String telefone = entregador['telefone'] ?? '---';
              final String token = entregador['token_vinculo'] ?? '---';
              final String placa = entregador['placa'] ?? '---';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: corVermelho,
                    child: Text(
                      nome[0].toUpperCase(),
                      style: const TextStyle(color: corBranco),
                    ),
                  ),
                  title: Text(
                    nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: corPreto,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("CPF: $cpf  |  Tel: $telefone"),
                      Text("Placa: $placa"),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(4),
                        color: corPreto,
                        child: Text(
                          "Token: $token",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: corBranco,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Usamos Row com mainAxisSize.min para colocar dois botões lado a lado
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão Copiar
                      IconButton(
                        icon: const Icon(Icons.copy),
                        color: corPreto,
                        tooltip: "Copiar Token",
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: token));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Token copiado!")),
                          );
                        },
                      ),
                      // Botão Excluir (Novo)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: corVermelho,
                        tooltip: "Excluir Entregador",
                        onPressed: () =>
                            _confirmarExclusao(context, docId, nome),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
