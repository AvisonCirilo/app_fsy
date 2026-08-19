import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'telas/login_tela.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ==========================================
// 1. O MENSAGEIRO GLOBAL DO TEMA
// ==========================================
final ValueNotifier<ThemeMode> temaGlobalNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // Garante que o Flutter está pronto para ler configurações nativas antes de arrancar
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 A IGNIÇÃO DO FIREBASE 🔥
  // Inicia o motor do Firebase usando as chaves geradas pelo terminal
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Lê a memória para ver se o Jovem/Consultor deixou o Modo Escuro ligado da última vez
  final prefs = await SharedPreferences.getInstance();
  bool modoEscuroAtivo = prefs.getBool('config_modo_escuro') ?? false;
  
  // Define a cor com que o aplicativo vai abrir
  temaGlobalNotifier.value = modoEscuroAtivo ? ThemeMode.dark : ThemeMode.light;

  runApp(const FsyApp());
}

// ==========================================
// A SUA CLASSE FsyApp CONTINUA EXATAMENTE IGUAL DAQUI PARA BAIXO...
// ==========================================
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
          
          home: const TelaLogin(), 
        );
      },
    );
  }
}