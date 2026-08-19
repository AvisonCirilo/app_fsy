/*import 'package:flutter/material.dart';

import '../components/meu_campo_texto.dart';
import '../components/meu_botao.dart';
import 'home_tela.dart';
import 'recuperar_senhas.dart';

class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 216), // Fundo claro como na sua imagem
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: SizedBox(
                width: 400,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Oficial do FSY
                    Image.asset(
                      'assets/images/logo.png',
                      height: 140, // Você pode aumentar ou diminuir esse número para ajustar o tamanho na tela
                    ),
                    const SizedBox(height: 30),

                    // Usando o nosso próprio Campo de Texto para Email
                    const MeuCampoTexto(
                      hintText: 'User',
                      obscureText: false,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 15),

                    // Usando o nosso próprio Campo de Texto para Senha
                    const MeuCampoTexto(
                      hintText: 'Password',
                      obscureText: true,
                     icon: Icons.key,
                    ),
                    const SizedBox(height: 10),

                    // Botão "Esqueceu a senha" alinhado à direita
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TelaRecuperarSenha(),
                              ),
                            );
                          },
                          child: Text(
                            'Forget Password',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Usando nosso Botão Principal (Amarelo)
                    MeuBotao(
                      texto: 'LOGIN',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TelaInicial(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/meu_campo_texto.dart';
import '../components/meu_botao.dart';
import 'home_tela.dart';
import 'recuperar_senhas.dart';

class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 216), // Fundo claro como na sua imagem
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Oficial do FSY
                    Image.asset(
                      'assets/images/logo.png',
                      height: 140, // Você pode aumentar ou diminuir esse número para ajustar o tamanho na tela
                    ),
                    const SizedBox(height: 30),

                    // Usando o nosso próprio Campo de Texto para Email
                    const MeuCampoTexto(
                      hintText: 'User',
                      obscureText: false,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 15),

                    // Usando o nosso próprio Campo de Texto para Senha
                    const MeuCampoTexto(
                      hintText: 'Password',
                      obscureText: true,
                      icon: Icons.key,
                    ),
                    const SizedBox(height: 10),

                    // Botão "Esqueceu a senha" alinhado à direita
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TelaRecuperarSenha(),
                              ),
                            );
                          },
                          child: Text(
                            'Forget Password',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // ==========================================
                    // BOTÃO DE LOGIN ATUALIZADO (INJETA O ADMIN)
                    // ==========================================
                    MeuBotao(
                      texto: 'LOGIN',
                      // Adicionamos o "async" aqui porque salvar na memória leva uma fração de segundo
                      onTap: () async { 
                        // 1. Abre a memória do telemóvel
                        final prefs = await SharedPreferences.getInstance();
                        
                        // 2. Força o acesso como Administrador
                        await prefs.setString('perfil_funcao', 'Administrador'); 
                        await prefs.setString('perfil_nome', 'Admin Principal');
                        await prefs.setString('perfil_companhia', 'Geral');

                        // 3. Segurança do Flutter: Verifica se a tela ainda está aberta antes de navegar
                        if (!context.mounted) return;

                        // 4. Navega para a tela principal
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TelaInicial(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}