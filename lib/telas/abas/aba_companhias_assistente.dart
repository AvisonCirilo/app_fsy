import 'package:flutter/material.dart';

import '../../data/app_permissions.dart';
import '../../data/local_auth_service.dart';
import '../../data/local_database.dart';

class AbaCompanhiasAssistente extends StatelessWidget {
  const AbaCompanhiasAssistente({super.key});

  Future<void> _adicionarMeta(
    BuildContext context,
    String companhiaId,
    List<dynamic> metasAtuais,
  ) async {
    final controller = TextEditingController();
    final texto = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nova meta'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Descreva a meta da companhia',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (texto == null || texto.isEmpty) return;

    final novasMetas = metasAtuais
        .map((meta) => Map<String, dynamic>.from(meta as Map))
        .toList();
    novasMetas.add({'texto': texto, 'concluido': false});

    await LocalDatabase.instance
        .collection('companhias')
        .doc(companhiaId)
        .update({'metas': novasMetas});
  }

  Future<void> _atualizarMeta(
    String companhiaId,
    List<dynamic> metasAtuais,
    int indice,
    bool concluido,
  ) async {
    final novasMetas = metasAtuais
        .map((meta) => Map<String, dynamic>.from(meta as Map))
        .toList();
    novasMetas[indice]['concluido'] = concluido;

    await LocalDatabase.instance
        .collection('companhias')
        .doc(companhiaId)
        .update({'metas': novasMetas});
  }

  Future<void> _removerMeta(
    String companhiaId,
    List<dynamic> metasAtuais,
    int indice,
  ) async {
    final novasMetas = metasAtuais
        .map((meta) => Map<String, dynamic>.from(meta as Map))
        .toList();
    novasMetas.removeAt(indice);

    await LocalDatabase.instance
        .collection('companhias')
        .doc(companhiaId)
        .update({'metas': novasMetas});
  }

  Widget _cartaoCompanhia(
    BuildContext context,
    String nomeCompanhia,
    bool isEscuro,
  ) {
    return StreamBuilder<LocalQuerySnapshot>(
      stream: LocalDatabase.instance
          .collection('companhias')
          .where('nome', isEqualTo: nomeCompanhia)
          .limit(1)
          .snapshots(),
      builder: (context, companhiaSnapshot) {
        if (companhiaSnapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!companhiaSnapshot.hasData ||
            companhiaSnapshot.data!.docs.isEmpty) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber, color: Colors.orange),
              title: Text(nomeCompanhia),
              subtitle: const Text('Companhia não encontrada no cadastro.'),
            ),
          );
        }

        final companhia = companhiaSnapshot.data!.docs.first;
        final dados = companhia.data();
        final metas = (dados['metas'] as List?) ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isEscuro ? Colors.white12 : Colors.grey.shade200,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        nomeCompanhia,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Adicionar meta',
                      onPressed: () =>
                          _adicionarMeta(context, companhia.id, metas),
                      icon: const Icon(Icons.add_circle, color: Colors.teal),
                    ),
                  ],
                ),
                const Divider(),
                const Text(
                  'Metas e acompanhamento',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (metas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Nenhuma meta cadastrada.'),
                  )
                else
                  ...List.generate(metas.length, (index) {
                    final meta = Map<String, dynamic>.from(metas[index] as Map);
                    final concluida = meta['concluido'] == true;

                    return Dismissible(
                      key: ValueKey(
                        '${companhia.id}_${meta['texto']}_$index',
                      ),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) =>
                          _removerMeta(companhia.id, metas, index),
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: concluida,
                        title: Text(meta['texto']?.toString() ?? ''),
                        onChanged: (value) => _atualizarMeta(
                          companhia.id,
                          metas,
                          index,
                          value ?? false,
                        ),
                      ),
                    );
                  }),
                const Divider(),
                StreamBuilder<LocalQuerySnapshot>(
                  stream: LocalDatabase.instance
                      .collection('jovens')
                      .where('companhia', isEqualTo: nomeCompanhia)
                      .snapshots(),
                  builder: (context, jovensSnapshot) {
                    final jovens = jovensSnapshot.data?.docs ?? [];

                    return ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text('Jovens vinculados (${jovens.length})'),
                      children: jovens.isEmpty
                          ? const [
                              ListTile(
                                title: Text('Nenhum jovem vinculado.'),
                              ),
                            ]
                          : jovens
                              .map(
                                (jovem) => ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.person_outline),
                                  title: Text(jovem['nome'].toString()),
                                  subtitle: Text(
                                    '${jovem['idade'] ?? '--'} anos',
                                  ),
                                ),
                              )
                              .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final perfil = LocalAuthService.instance.currentUser?.profile ?? {};
    final permissoes = AppPermissions.fromProfile(perfil);
    final isEscuro = Theme.of(context).brightness == Brightness.dark;

    if (!permissoes.isAssistantCoordinator) {
      return const Center(
        child: Text('Esta área é exclusiva dos Coordenadores Assistentes.'),
      );
    }

    final companhias = permissoes.assignedCompanies.take(2).toList();

    if (companhias.length != 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Seu usuário ainda não possui duas companhias atribuídas. '
            'Solicite à Coordenação que configure suas responsabilidades.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minhas Companhias',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Acompanhamento operacional das duas companhias sob sua responsabilidade.',
            style: TextStyle(
              color: isEscuro ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          for (final companhia in companhias)
            _cartaoCompanhia(context, companhia, isEscuro),
        ],
      ),
    );
  }
}
