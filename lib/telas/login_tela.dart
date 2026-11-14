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
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : const Color.fromARGB(255, 242, 245, 207),
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
                    Image.asset('assets/images/logo.png', height: 280),
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
                          child: Text(
                            'Forget Password',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
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