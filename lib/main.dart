import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NOVO: Importação da Autenticação

import 'firebase_options.dart';
import 'telas/login_tela.dart';
import 'telas/home_tela.dart'; // NOVO: Importamos a tela inicial para o atalho

// ==========================================
// 1. O MENSAGEIRO GLOBAL DO TEMA
// ==========================================
final ValueNotifier<ThemeMode> temaGlobalNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final prefs = await SharedPreferences.getInstance();
  bool modoEscuroAtivo = prefs.getBool('config_modo_escuro') ?? false;
  
  temaGlobalNotifier.value = modoEscuroAtivo ? ThemeMode.dark : ThemeMode.light;

  runApp(const FsyApp());
}

class FsyApp extends StatelessWidget {
  const FsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaGlobalNotifier,
      builder: (context, modoAtual, child) {
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'App FSY',
          themeMode: modoAtual,
          
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey[50], 
          ),
          
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF121212), 
            cardColor: const Color(0xFF1E1E1E), 
            colorScheme: ColorScheme.fromSwatch(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
            ).copyWith(
              secondary: Colors.blueAccent,
            ),
          ),
          
          // A MÁGICA ACONTECE AQUI: Em vez de apontar para a TelaLogin, aponta para o Guarda!
          home: const ChecadorDeSessao(), 
        );
      },
    );
  }
}

// ==========================================
// 2. O GUARDA DA PORTA (VERIFICA A SESSÃO SALVA)
// ==========================================
class ChecadorDeSessao extends StatelessWidget {
  const ChecadorDeSessao({super.key});

  @override
  Widget build(BuildContext context) {
    // O StreamBuilder fica a "escutar" o Firebase para saber se a pessoa já tem a chave de acesso
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // Enquanto o Firebase procura a chave na memória do telemóvel, mostra a bolinha a girar
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.blue)),
          );
        }
        
        // Se encontrou uma chave válida (alguém fez login antes e não clicou em "Sair")
        if (snapshot.hasData) {
          return const TelaInicial(); // Vai direto para dentro do App!
        }
        
        // Se não encontrou chave nenhuma, aí sim obriga a fazer Login
        return const TelaLogin();
      },
    );
  }
}