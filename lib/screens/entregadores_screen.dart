import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rotago_web/repositories/entregadores_repository.dart';

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
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              try {
                // 1. Apaga do Firebase via Repository
                await EntregadoresRepository().deleteEntregador(docId);

                // 2. Fecha o alerta
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Entregador excluído com sucesso!"),
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erro ao excluir: $e")),
                  );
                }
              }
            },
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cores globais do tema
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Instância do Repository
    final repository = EntregadoresRepository();

    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciar Entregadores")),
      body: StreamBuilder<QuerySnapshot>(
        stream: repository.getEntregadoresStream(),
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
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                  ),
                  title: Text(
                    nome,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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
                        color: Colors.black, // Mantendo preto para destaque do token
                        child: Text(
                          "Token: $token",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy),
                        color: Colors.black,
                        tooltip: "Copiar Token",
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: token));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Token copiado!")),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: colorScheme.error),
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
