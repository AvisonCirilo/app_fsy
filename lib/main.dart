import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'telas/login_tela.dart';

// Importe aqui as suas telas, por exemplo:
// import 'telas/home_tela.dart'; 

// ==========================================
// 1. O MENSAGEIRO GLOBAL DO TEMA
// (Tem de ficar aqui em cima, fora de qualquer classe)
// ==========================================
final ValueNotifier<ThemeMode> temaGlobalNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // Garante que o Flutter está pronto para ler a memória do telemóvel antes de arrancar
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lê a memória para ver se o Jovem/Consultor deixou o Modo Escuro ligado da última vez
  final prefs = await SharedPreferences.getInstance();
  bool modoEscuroAtivo = prefs.getBool('config_modo_escuro') ?? false;
  
  // Define a cor com que o aplicativo vai abrir
  temaGlobalNotifier.value = modoEscuroAtivo ? ThemeMode.dark : ThemeMode.light;

  runApp(const FsyApp());
}

class FsyApp extends StatelessWidget {
  const FsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // 2. O OUVINTE: Fica à espera que o botão do perfil seja clicado
    // ==========================================
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaGlobalNotifier,
      builder: (context, modoAtual, child) {
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'App FSY',
          
          // 3. A MÁGICA: O tema do app muda automaticamente aqui!
          themeMode: modoAtual,
          
          // --- CONFIGURAÇÃO DO MODO CLARO ---
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey[50], // Fundo levemente cinza
          ),
          
          // --- CONFIGURAÇÃO DO MODO ESCURO ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF121212), // Cinza super escuro (Padrão Premium)
            cardColor: const Color(0xFF1E1E1E), // Cor dos cartões (Cards) no escuro
            
            // Define a cor azul padrão mesmo no modo escuro
            colorScheme: ColorScheme.fromSwatch(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
            ).copyWith(
              secondary: Colors.blueAccent,
            ),
          ),
          
          // ATENÇÃO: Substitua isto pela sua verdadeira tela inicial (a que tem a barra inferior de navegação)
          home: const TelaLogin(), // Ex: const HomeTela()
        );
      },
    );
  }
}