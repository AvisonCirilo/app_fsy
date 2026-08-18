import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './abas/aba_inicio.dart';
import './abas/aba_agenda.dart';
import './abas/aba_jovens.dart';
import './abas/aba_perfil.dart';
import './abas/aba_admin.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  int _indiceAtual = 0;
  bool _carregando = true;

  // Em vez de serem listas fixas (const/final), agora são variáveis dinâmicas!
  List<Widget> _secoes = [];
  List<BottomNavigationBarItem> _itensBarra = [];

  @override
  void initState() {
    super.initState();
    _construirAbasPorPermissao();
  }

  // A MÁGICA DE PERMISSÕES ACONTECE AQUI
  Future<void> _construirAbasPorPermissao() async {
    final prefs = await SharedPreferences.getInstance();
    
    // O App vai ler secretamente o que está escrito no campo "Função" do seu Perfil
    String funcaoSalva = prefs.getString('perfil_funcao') ?? "";
    
    // Verifica se a palavra "admin" ou "administrador" está lá dentro (ignorando maiúsculas)
    bool isAdmin = funcaoSalva.toLowerCase().contains('admin');

    // 1. Constrói as 4 abas normais para todos
    List<Widget> telasTemp = [
      const AbaInicio(),
      const AbaAgenda(),
      const AbaJovens(),
      const AbaPerfil(),
    ];

    List<BottomNavigationBarItem> botoesTemp = [
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
      const BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Agenda'),
      const BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'Jovens'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
    ];

    // 2. SE FOR ADMINISTRADOR, ELE INJETA O MODO DEUS NAS LISTAS!
    if (isAdmin) {
      telasTemp.add(const AbaAdmin()); // 5ª Aba
      botoesTemp.add(const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings_outlined), 
        activeIcon: Icon(Icons.admin_panel_settings), 
        label: 'Admin'
      ));
    }

    // Salva na memória da tela para o aplicativo renderizar
    setState(() {
      _secoes = telasTemp;
      _itensBarra = botoesTemp;
      _carregando = false;
    });
  }

  void _aoTocarNaAba(int indice) {
    setState(() {
      _indiceAtual = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se ainda estiver lendo a memória, mostra bolinha de carregamento
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/logo.png',
          height: 40, 
        ),
        backgroundColor: isEscuro ? const Color(0xFF1E1E1E) : const Color.fromARGB(255, 220, 255, 216),
        foregroundColor: isEscuro ? Colors.white : Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none), 
            onPressed: () {},
          ),
        ],
      ),

      // Chama as secções que foram construídas magicamente
      body: _secoes[_indiceAtual],

      // Chama os botões que foram construídos magicamente
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: isEscuro ? Colors.lightBlueAccent : const Color(0xFF003366), 
        unselectedItemColor: isEscuro ? Colors.white54 : Colors.grey,
        
        currentIndex: _indiceAtual,
        onTap: _aoTocarNaAba,
        items: _itensBarra, // <-- Agora puxa a lista dinâmica!
      ),
    );
  }
}