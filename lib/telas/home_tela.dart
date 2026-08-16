import 'package:app_fsy/telas/abas/aba_perfil.dart';
import 'package:flutter/material.dart';

import './abas/aba_inicio.dart';
import './abas/aba_agenda.dart';
import './abas/aba_jovens.dart';
//import './abas/aba_perfil.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  // Essa variável guarda qual "aba" está selecionada (começa no 0, que é o Início)
  int _indiceAtual = 0;

  // Lista de "Telas" que vão aparecer no meio do aplicativo dependendo da aba escolhida
  final List<Widget> _secoes = [
    const AbaInicio(),
    const AbaAgenda(), // Índice 1
    const AbaJovens(), // Índice 2
    const AbaPerfil(), // Índice 3
  ];

  // Função que roda quando clicamos em um ícone da barra
  void _aoTocarNaAba(int indice) {
    setState(() {
      _indiceAtual = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      // A barra superior
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/logo.png',
          height: 40, // Altura limitada para não estourar o tamanho da barra
        ),

        backgroundColor: const Color.fromARGB(255, 220, 255, 216), //Verde
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
            ), // Ícone de notificações estilo rede social
            onPressed: () {},
          ),
        ],
      ),

      // O "Corpo" do aplicativo agora muda dependendo do _indiceAtual
      body: _secoes[_indiceAtual],

      // A Mágica da Rede Social: A Barra Inferior
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // Mantém os ícones fixos mesmo se tiver muitos
        backgroundColor: Colors.white,
        selectedItemColor: const Color(
          0xFF003366,
        ), // Azul escuro para o item selecionado
        unselectedItemColor: Colors.grey,
        currentIndex: _indiceAtual,
        onTap: _aoTocarNaAba,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Jovens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
