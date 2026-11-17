import 'package:flutter/material.dart';

import '../../data/app_permissions.dart';
import '../../data/local_auth_service.dart';
import '../../data/local_database.dart';
import '../../data/lodging_structure.dart';
import 'admin/mapa_alojamentos.dart';

class AbaLogistica extends StatelessWidget {
  const AbaLogistica({super.key});

  void _abrirDetalhes(BuildContext context, int abaInicial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapaAlojamentos(initialTabIndex: abaInicial),
      ),
    );
  }

  Widget _indicador(
    BuildContext context, {
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
    required VoidCallback onTap,
  }) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(16);

    return SizedBox(
      width: 155,
      child: Material(
        color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: isEscuro ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icone, color: cor, size: 25),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  titulo,
                  style: TextStyle(
                    color: isEscuro ? Colors.white60 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = LocalAuthService.instance.currentUser?.profile ?? {};
    final permissions = AppPermissions.fromProfile(profile);

    if (!permissions.canAccessLodging) {
      return const Center(
        child: Text('Você não tem permissão para acessar a área de Logística.'),
      );
    }

    return StreamBuilder<LocalQuerySnapshot>(
      stream: LocalDatabase.instance.collection('jovens').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível carregar os dados de alojamento.'),
          );
        }

        final jovens = snapshot.data?.docs ?? [];
        final alojados = jovens.where(LodgingStructure.isAssigned).length;
        final pendentes = jovens.length - alojados;
        final quartosEmUso = LodgingStructure.countRooms(jovens);
        final isEscuro = Theme.of(context).brightness == Brightness.dark;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Central de Logística',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Acompanhamento de hospedagem e distribuição dos jovens.',
                style: TextStyle(
                  color: isEscuro ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toque em um indicador para consultar os detalhes.',
                style: TextStyle(
                  fontSize: 12,
                  color: isEscuro ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _indicador(
                    context,
                    titulo: 'Jovens cadastrados',
                    valor: jovens.length.toString(),
                    icone: Icons.groups,
                    cor: Colors.blue,
                    onTap: () => _abrirDetalhes(context, 0),
                  ),
                  _indicador(
                    context,
                    titulo: 'Jovens alojados',
                    valor: alojados.toString(),
                    icone: Icons.bed,
                    cor: Colors.green,
                    onTap: () => _abrirDetalhes(context, 1),
                  ),
                  _indicador(
                    context,
                    titulo: 'Sem alojamento',
                    valor: pendentes.toString(),
                    icone: Icons.person_search,
                    cor: Colors.orange,
                    onTap: () => _abrirDetalhes(context, 2),
                  ),
                  _indicador(
                    context,
                    titulo: 'Quartos em uso',
                    valor: quartosEmUso.toString(),
                    icone: Icons.meeting_room,
                    cor: Colors.indigo,
                    onTap: () => _abrirDetalhes(context, 1),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Card(
                elevation: 0,
                color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isEscuro ? Colors.white12 : Colors.grey.shade200,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0x1F3F51B5),
                    child: Icon(Icons.hotel, color: Colors.indigo),
                  ),
                  title: const Text(
                    'Mapa de Alojamentos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Visualize os andares, consulte os quartos e faça alocações.',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _abrirDetalhes(context, 1),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Seu acesso é voltado à hospedagem. O cadastro geral dos jovens e a estrutura das companhias são administrados pela Direção e Coordenação.',
                style: TextStyle(
                  fontSize: 12,
                  color: isEscuro ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
