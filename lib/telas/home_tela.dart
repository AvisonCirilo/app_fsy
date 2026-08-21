import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './abas/aba_inicio.dart';
import './abas/aba_agenda.dart';
import 'abas/aba_companhia.dart';
import './abas/aba_perfil.dart';
import './abas/aba_admin.dart';

// NOVO: Importamos a tela de Lista de Jovens para poder colocá-la na barra debaixo!
import './abas/admin/lista_jovens.dart'; 

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  int _indiceAtual = 0;
  bool _carregando = true;

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
    
    // O App lê secretamente o que está escrito no campo "Função" do Perfil
    String funcaoSalva = prefs.getString('perfil_funcao') ?? "";
    
    bool isAdmin = funcaoSalva.toLowerCase().contains('admin');
    bool isLogistica = funcaoSalva == 'Logística'; // Verifica se o perfil é o da Logística

    // 1. As abas que todos têm em comum (Início e Agenda)
    List<Widget> telasTemp = [
      AbaInicio(
        irParaAgenda: () {
          _aoTocarNaAba(1); 
        },
      ),
      const AbaAgenda(),
    ];

    List<BottomNavigationBarItem> botoesTemp = [
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
      const BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Agenda'),
    ];

    // ==========================================
    // 2. A ABA DO MEIO (Muda consoante o cargo!)
    // ==========================================
    if (isLogistica) {
      // Se for Logística, ele substitui a Companhia pela Lista de Jovens!
      telasTemp.add(const ListaJovensTela());
      botoesTemp.add(const BottomNavigationBarItem(
        icon: Icon(Icons.format_list_bulleted), 
        activeIcon: Icon(Icons.list), 
        label: 'Jovens'
      ));
    } else {
      // Para os outros líderes, continua a ser a Aba de Companhia
      telasTemp.add(const AbaCompanhia());
      botoesTemp.add(const BottomNavigationBarItem(
        icon: Icon(Icons.groups_outlined), 
        activeIcon: Icon(Icons.groups), 
        label: 'Companhia'
      ));
    }

    // 3. A aba Perfil vai logo a seguir
    telasTemp.add(const AbaPerfil());
    botoesTemp.add(const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'));

    // 4. SE FOR ADMINISTRADOR, ELE INJETA A 5ª ABA "MODO DEUS"
    if (isAdmin) {
      telasTemp.add(const AbaAdmin());
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
      body: _secoes[_indiceAtual],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: isEscuro ? Colors.lightBlueAccent : const Color(0xFF003366), 
        unselectedItemColor: isEscuro ? Colors.white54 : Colors.grey,
        
        currentIndex: _indiceAtual,
        onTap: _aoTocarNaAba,
        items: _itensBarra, 
      ),
    );
  }
}