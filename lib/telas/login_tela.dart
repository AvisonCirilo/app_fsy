import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/meu_campo_texto.dart';
import '../components/meu_botao.dart';
import 'home_tela.dart';
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

  Future<void> _fazerLoginFirebase() async {
    String user = _userController.text.trim().toLowerCase();
    String senha = _senhaController.text.trim();

    if (user.isEmpty || senha.isEmpty) {
      _mostrarAviso("Por favor, preencha o utilizador e a senha.");
      return;
    }

    setState(() => _carregando = true);
    String emailFormatado = "$user@fsy.com"; // Truque para o Firebase aceitar o login curto

    try {
      // 1. Valida a senha no Firebase Auth
      UserCredential credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailFormatado, password: senha,
      );

      // 2. Puxa a "Ficha" da pessoa no Banco de Dados Firestore
      DocumentSnapshot docUsuario = await FirebaseFirestore.instance.collection('usuarios').doc(credencial.user!.uid).get();

      if (docUsuario.exists) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('perfil_funcao', docUsuario['funcao'] ?? 'Consultor');
        await prefs.setString('perfil_nome', docUsuario['nome'] ?? 'Usuário');
        await prefs.setString('perfil_usuario', user);
        await prefs.setString('perfil_companhia', docUsuario['companhia'] ?? 'A Definir');

        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TelaInicial()));
      } else {
        _mostrarAviso("Ficha do usuário não encontrada no banco.");
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException {
      // PORTA SECRETA: Se o banco estiver vazio, cria o 1º Admin
      if (user == 'admin' && senha == 'fsy2026') {
         await _criarPrimeiroAdmin(emailFormatado, senha);
      } else {
        _mostrarAviso("Usuário ou senha incorretos.");
      }
    } catch (e) {
      _mostrarAviso("Erro de conexão: $e");
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _criarPrimeiroAdmin(String email, String senha) async {
    try {
      UserCredential credencial = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: senha);
      await FirebaseFirestore.instance.collection('usuarios').doc(credencial.user!.uid).set({
        'nome': 'Admin Principal', 'funcao': 'Administrador', 'usuario': 'admin', 'companhia': 'Geral', 'saude': 'Nenhuma', 'medicamento': '',
      });
      _mostrarAviso("Conta Mestre criada! Clique em LOGIN novamente.", cor: Colors.green);
    } catch (e) {
      _mostrarAviso("Erro ao criar Admin: $e");
    }
  }

  void _mostrarAviso(String mensagem, {Color cor = Colors.redAccent}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem), backgroundColor: cor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 216),
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
                    Image.asset('assets/images/logo.png', height: 140),
                    const SizedBox(height: 30),
                    
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
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaRecuperarSenha())),
                          child: Text('Forget Password', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    _carregando 
                      ? const CircularProgressIndicator(color: Colors.amber)
                      : MeuBotao(texto: 'LOGIN', onTap: _fazerLoginFirebase),
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
}
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
}*/