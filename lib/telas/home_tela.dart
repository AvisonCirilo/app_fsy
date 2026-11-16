import 'package:flutter/material.dart';

import '../data/app_permissions.dart';
import '../data/local_auth_service.dart';
import 'abas/aba_inicio.dart';
import 'abas/aba_agenda.dart';
import 'abas/aba_companhia.dart';
import 'abas/aba_companhias_assistente.dart';
import 'abas/aba_logistica.dart';
import 'abas/aba_perfil.dart';
import 'abas/aba_admin.dart';

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

  void _construirAbasPorPermissao() {
    final perfil = LocalAuthService.instance.currentUser?.profile ?? {};
    final permissoes = AppPermissions.fromProfile(perfil);

    final telas = <Widget>[
      AbaInicio(
        irParaAgenda: () => _aoTocarNaAba(1),
      ),
      const AbaAgenda(),
    ];

    final botoes = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Início',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        activeIcon: Icon(Icons.calendar_month),
        label: 'Agenda',
      ),
    ];

    if (permissoes.isLogistics) {
      telas.add(const AbaLogistica());
      botoes.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.hotel_outlined),
          activeIcon: Icon(Icons.hotel),
          label: 'Logística',
        ),
      );
    } else if (permissoes.isAssistantCoordinator) {
      telas.add(const AbaCompanhiasAssistente());
      botoes.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.groups_outlined),
          activeIcon: Icon(Icons.groups),
          label: 'Companhias',
        ),
      );
    } else {
      telas.add(const AbaCompanhia());
      botoes.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.groups_outlined),
          activeIcon: Icon(Icons.groups),
          label: 'Companhia',
        ),
      );
    }

    telas.add(const AbaPerfil());
    botoes.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Perfil',
      ),
    );

    if (permissoes.canAccessAdminPanel) {
      telas.add(const AbaAdmin());
      botoes.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Gestão',
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _secoes = telas;
      _itensBarra = botoes;
      _indiceAtual = 0;
      _carregando = false;
    });
  }

  void _aoTocarNaAba(int indice) {
    if (indice < 0 || indice >= _secoes.length) return;
    setState(() => _indiceAtual = indice);
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/logo.png',
          height: 40,
        ),
        backgroundColor: isEscuro
            ? const Color(0xFF1E1E1E)
            : const Color.fromARGB(255, 220, 255, 216),
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
        selectedItemColor:
            isEscuro ? Colors.lightBlueAccent : const Color(0xFF003366),
        unselectedItemColor: isEscuro ? Colors.white54 : Colors.grey,
        currentIndex: _indiceAtual,
        onTap: _aoTocarNaAba,
        items: _itensBarra,
      ),
    );
  }
}
