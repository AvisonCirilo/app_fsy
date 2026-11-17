import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/local_auth_service.dart';
import 'data/local_database.dart';
import 'telas/login_tela.dart';
import 'telas/home_tela.dart';

final ValueNotifier<ThemeMode> temaGlobalNotifier =
    ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // O ambiente atual utiliza exclusivamente autenticação e dados locais.
  await LocalDatabase.instance.initialize();
  await LocalAuthService.instance.initialize();

  final prefs = await SharedPreferences.getInstance();
  final seguirTemaSistema =
      prefs.getBool('config_seguir_tema_sistema') ?? true;
  final modoEscuroAtivo = prefs.getBool('config_modo_escuro') ?? false;

  temaGlobalNotifier.value = seguirTemaSistema
      ? ThemeMode.system
      : (modoEscuroAtivo ? ThemeMode.dark : ThemeMode.light);

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
            ).copyWith(secondary: Colors.blueAccent),
          ),
          home: const ChecadorDeSessao(),
        );
      },
    );
  }
}

class ChecadorDeSessao extends StatelessWidget {
  const ChecadorDeSessao({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LocalAuthUser?>(
      stream: LocalAuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
          );
        }

        if (snapshot.hasData) return const TelaInicial();
        return const TelaLogin();
      },
    );
  }
}
