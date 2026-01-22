import 'package:flutter/material.dart';
import 'package:rotago_web/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isLogin = true; // Se true, mostra Login. Se false, mostra Cadastro.

  // Função que chama o AuthService
  void _submit() async {
    setState(() => _isLoading = true);

    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();

    try {
      if (_isLogin) {
        // Tentar Logar
        await _authService.login(email, senha);
      } else {
        // Tentar Cadastrar
        await _authService.cadastro(email, senha);
      }
      // Se der certo, não precisamos fazer nada aqui,
      // o main.dart vai detectar a mudança e trocar de tela automaticamente.
    } catch (e) {
      // Se der erro, mostra um alerta
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: ${e.toString()}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          elevation: 5,
          child: Container(
            width: 400, // Largura fixa para ficar bonito no PC
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isLogin ? "RotaGo Login" : "Criar Conta RotaGo",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "E-mail",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _senhaController,
                  decoration: const InputDecoration(
                    labelText: "Senha",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text(_isLogin ? "ENTRAR" : "CADASTRAR"),
                        ),
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin; // Alterna entre Login e Cadastro
                    });
                  },
                  child: Text(
                    _isLogin
                        ? "Não tem conta? Crie uma aqui."
                        : "Já tem conta? Faça login.",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
