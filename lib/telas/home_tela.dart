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

  List<NavigationRailDestination> _destinosDaNavegacao() {
    return _itensBarra
        .map(
          (item) => NavigationRailDestination(
            icon: item.icon,
            selectedIcon: item.activeIcon,
            label: Text(item.label ?? ''),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    final largura = MediaQuery.sizeOf(context).width;
    final usarNavegacaoLateral = largura >= 800;
    final menuExpandido = largura >= 1100;
    final corMenu = isEscuro ? const Color(0xFF1E1E1E) : Colors.white;
    final corSelecionada =
        isEscuro ? Colors.lightBlueAccent : const Color(0xFF003366);

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
            tooltip: 'Notificações',
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Row(
        children: [
          if (usarNavegacaoLateral) ...[
            NavigationRail(
              selectedIndex: _indiceAtual,
              onDestinationSelected: _aoTocarNaAba,
              extended: menuExpandido,
              labelType: menuExpandido
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              minWidth: 76,
              minExtendedWidth: 220,
              backgroundColor: corMenu,
              selectedIconTheme: IconThemeData(color: corSelecionada),
              unselectedIconTheme: IconThemeData(
                color: isEscuro ? Colors.white54 : Colors.grey.shade600,
              ),
              selectedLabelTextStyle: TextStyle(
                color: corSelecionada,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: isEscuro ? Colors.white60 : Colors.black54,
              ),
              leading: menuExpandido
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 42,
                        fit: BoxFit.contain,
                      ),
                    )
                  : const SizedBox(height: 12),
              destinations: _destinosDaNavegacao(),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: isEscuro ? Colors.white12 : Colors.black12,
            ),
          ],
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: _secoes[_indiceAtual],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: usarNavegacaoLateral
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: corMenu,
              selectedItemColor: corSelecionada,
              unselectedItemColor: isEscuro ? Colors.white54 : Colors.grey,
              currentIndex: _indiceAtual,
              onTap: _aoTocarNaAba,
              items: _itensBarra,
            ),
    );
  }
}
