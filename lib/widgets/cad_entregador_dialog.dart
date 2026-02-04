import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:rotago_web/repositories/entregadores_repository.dart';

class NovoEntregadorDialog extends StatefulWidget {
  const NovoEntregadorDialog({super.key});

  @override
  State<NovoEntregadorDialog> createState() => _NovoEntregadorDialogState();
}

class _NovoEntregadorDialogState extends State<NovoEntregadorDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para pegar o texto
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _placaController = TextEditingController();

  bool _salvando = false;

  Future<void> _salvarNoBanco() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      var uuid = const Uuid();
      // Gera um token de 6 caracteres maiúsculos (ex: A1B2C3) para ser fácil digitar
      String tokenGerado = uuid.v4().substring(0, 6).toUpperCase();

      final data = {
        'nome': _nomeController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'placa': _placaController.text.trim().toUpperCase(),
        'token_vinculo': tokenGerado,
        'status': 'offline',
        // Localização inicial (Centro de Maringá)
        'localizacao_atual': {'lat': -23.420999, 'lng': -51.933056},
        // 'criado_em' será adicionado pelo repository
      };

      // Uso do Repository para salvar
      await EntregadoresRepository().addEntregador(data);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cadastrado! Token de acesso: $tokenGerado"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Novo Entregador"),
      content: SizedBox(
        width: 400, // Largura fixa para ficar bom no PC
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome Completo",
                  icon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? "Obrigatório" : null,
              ),
              const SizedBox(height: 10),
              // Linha com CPF e Telefone lado a lado
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cpfController,
                      decoration: const InputDecoration(
                        labelText: "CPF",
                        icon: Icon(Icons.badge),
                      ),
                      validator: (v) => v!.isEmpty ? "Obrigatório" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _telefoneController,
                      decoration: const InputDecoration(
                        labelText: "Telefone",
                        icon: Icon(Icons.phone),
                      ),
                      validator: (v) => v!.isEmpty ? "Obrigatório" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(
                  labelText: "Placa da Moto",
                  icon: Icon(Icons.motorcycle),
                ),
                validator: (v) => v!.isEmpty ? "Obrigatório" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        _salvando
            ? const Padding(
                padding: EdgeInsets.only(right: 20),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : ElevatedButton(
                onPressed: _salvarNoBanco,
                child: const Text("Salvar"),
              ),
      ],
    );
  }
}
