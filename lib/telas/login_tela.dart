import 'package:flutter/material.dart';
import '../data/local_auth_service.dart';

import '../components/meu_campo_texto.dart';
import '../components/meu_botao.dart';
import 'recuperar_senhas.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _carregando = false;

  Future<void> _fazerLoginLocal() async {
    final user = _userController.text.trim().toLowerCase();
    final senha = _senhaController.text.trim();

    if (user.isEmpty || senha.isEmpty) {
      _mostrarAviso("Por favor, preencha o utilizador e a senha.");
      return;
    }

    setState(() => _carregando = true);

    try {
      // O serviço local valida a credencial e restaura o perfil salvo.
      await LocalAuthService.instance.signIn(user, senha);
      // O ChecadorDeSessao observa a sessão e abre a área do aplicativo.
    } on LocalAuthException catch (e) {
      _mostrarAviso(e.message);
    } catch (e) {
      _mostrarAviso("Não foi possível entrar: $e");
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _mostrarAviso(String mensagem, {Color cor = Colors.redAccent}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: cor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isEscuro
          ? const Color(0xFF121212)
          : const Color.fromARGB(255, 242, 245, 207),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final telaCompacta =
                constraints.maxWidth < 380 || constraints.maxHeight < 700;
            final alturaLogo = telaCompacta ? 180.0 : 230.0;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: alturaLogo,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: telaCompacta ? 18 : 28),
                        MeuCampoTexto(
                          controller: _userController,
                          hintText: 'User (Ex: admin)',
                          obscureText: false,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 15),
                        MeuCampoTexto(
                          controller: _senhaController,
                          hintText: 'Password',
                          obscureText: true,
                          icon: Icons.key,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TelaRecuperarSenha(),
                                ),
                              ),
                              child: Text(
                                'Forget Password',
                                style: TextStyle(
                                  color: isEscuro
                                      ? Colors.white70
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        _carregando
                            ? const CircularProgressIndicator(
                                color: Colors.amber,
                              )
                            : MeuBotao(
                                texto: 'LOGIN',
                                onTap: _fazerLoginLocal,
                              ),
                        const SizedBox(height: 18),
                        Text(
                          'Ambiente de desenvolvimento • dados locais',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: isEscuro
                                ? Colors.white54
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
