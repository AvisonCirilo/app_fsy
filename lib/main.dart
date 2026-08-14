import 'package:flutter/material.dart';

import 'telas/login_tela.dart'; // Importa o arquivo de login que criamos

void main() {
  runApp(const FsyApp());
}

class FsyApp extends StatelessWidget {
  const FsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App FSY',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      home: const TelaLogin(), // Agora o app começa direto na Tela de Login!
    );
  }
}
