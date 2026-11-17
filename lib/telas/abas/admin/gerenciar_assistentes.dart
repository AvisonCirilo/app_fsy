import 'package:flutter/material.dart';

import '../../../data/app_permissions.dart';
import '../../../data/local_auth_service.dart';
import '../../../data/local_database.dart';

class GerenciarAssistentes extends StatefulWidget {
  const GerenciarAssistentes({super.key});

  @override
  State<GerenciarAssistentes> createState() => _GerenciarAssistentesState();
}

class _GerenciarAssistentesState extends State<GerenciarAssistentes> {
  Future<void> _abrirFormulario({LocalDocumentSnapshot? assistente}) async {
    final snapshot =
        await LocalDatabase.instance.collection('companhias').snapshots().first;
    if (!mounted) return;

    final companhias = snapshot.docs
        .map((doc) => (doc['nome'] ?? '').toString())
        .where((nome) => nome.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final dados = assistente?.data() ?? <String, dynamic>{};
    final atribuicoes = dados['companhiasResponsaveis'] is List
        ? List<String>.from(dados['companhiasResponsaveis'])
        : <String>[];

    String? primeiraCompanhia =
        atribuicoes.isNotEmpty ? atribuicoes[0] : null;
    String? segundaCompanhia =
        atribuicoes.length > 1 ? atribuicoes[1] : null;

    final nomeController =
        TextEditingController(text: (dados['nome'] ?? '').toString());
    final usuarioController =
        TextEditingController(text: (dados['usuario'] ?? '').toString());
    final senhaController = TextEditingController();

    final isEdicao = assistente != null;
    final isEscuro = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 22,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEdicao
                      ? 'Editar Coordenador Assistente'
                      : 'Novo Coordenador Assistente',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: usuarioController,
                  enabled: !isEdicao,
                  decoration: const InputDecoration(
                    labelText: 'Usuário de acesso',
                    prefixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(),
                  ),
                ),
                if (!isEdicao) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha (mínimo 6 caracteres)',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Text(
                  'Companhias sob responsabilidade',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: companhias.contains(primeiraCompanhia)
                      ? primeiraCompanhia
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Primeira companhia',
                    border: OutlineInputBorder(),
                  ),
                  items: companhias
                      .map(
                        (nome) => DropdownMenuItem(
                          value: nome,
                          child: Text(nome),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setSheetState(() {
                      primeiraCompanhia = value;
                      if (segundaCompanhia == value) {
                        segundaCompanhia = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: companhias.contains(segundaCompanhia) &&
                          segundaCompanhia != primeiraCompanhia
                      ? segundaCompanhia
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Segunda companhia',
                    border: OutlineInputBorder(),
                  ),
                  items: companhias
                      .where((nome) => nome != primeiraCompanhia)
                      .map(
                        (nome) => DropdownMenuItem(
                          value: nome,
                          child: Text(nome),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setSheetState(() => segundaCompanhia = value),
                ),
                if (companhias.length < 2)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'É necessário cadastrar pelo menos duas companhias antes de atribuir um assistente.',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (nomeController.text.trim().isEmpty ||
                          primeiraCompanhia == null ||
                          segundaCompanhia == null ||
                          primeiraCompanhia == segundaCompanhia) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Informe o nome e selecione duas companhias diferentes.',
                            ),
                          ),
                        );
                        return;
                      }

                      if (!isEdicao &&
                          (usuarioController.text.trim().isEmpty ||
                              senhaController.text.trim().length < 6)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Informe um usuário e uma senha com pelo menos 6 caracteres.',
                            ),
                          ),
                        );
                        return;
                      }

                      final atribuicoes = [
                        primeiraCompanhia!,
                        segundaCompanhia!,
                      ];

                      Navigator.pop(sheetContext);
                      try {
                        if (isEdicao) {
                          await LocalAuthService.instance.updateAccountProfile(
                            uid: assistente.id,
                            updates: {
                              'nome': nomeController.text.trim(),
                              'funcao': AppPermissions.assistantCoordinator,
                              'companhia': atribuicoes.first,
                              'companhiasResponsaveis': atribuicoes,
                            },
                          );
                        } else {
                          await LocalAuthService.instance.createAccount(
                            username:
                                usuarioController.text.trim().toLowerCase(),
                            password: senhaController.text.trim(),
                            profile: {
                              'nome': nomeController.text.trim(),
                              'funcao': AppPermissions.assistantCoordinator,
                              'companhia': atribuicoes.first,
                              'companhiasResponsaveis': atribuicoes,
                              'saude': 'Nenhuma',
                              'medicamento': '',
                            },
                          );
                        }

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdicao
                                    ? 'Assistente atualizado com sucesso.'
                                    : 'Assistente cadastrado com sucesso.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (error) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Não foi possível salvar: $error'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: Text(isEdicao ? 'Salvar alterações' : 'Cadastrar assistente'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    nomeController.dispose();
    usuarioController.dispose();
    senhaController.dispose();
  }

  Future<void> _excluirAssistente(LocalDocumentSnapshot assistente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir coordenador assistente?'),
        content: Text(
          'A conta de ${assistente['nome']} será removida deste ambiente local.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await LocalAuthService.instance.deleteAccount(assistente.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assistente removido.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível excluir: $error'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissoes = AppPermissions.fromProfile(
      LocalAuthService.instance.currentUser?.profile ?? {},
    );
    if (!permissoes.canManageAssistantTeam) {
      return Scaffold(
        appBar: AppBar(title: const Text('Equipe de Assistentes')),
        body: const Center(
          child: Text('Você não tem permissão para gerenciar assistentes.'),
        ),
      );
    }

    final isEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Coordenadores Assistentes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Novo assistente'),
      ),
      body: StreamBuilder<LocalQuerySnapshot>(
        stream: LocalDatabase.instance.collection('usuarios').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final assistentes = (snapshot.data?.docs ?? [])
              .where(
                (doc) =>
                    doc['funcao'] == AppPermissions.assistantCoordinator,
              )
              .toList();

          if (assistentes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhum coordenador assistente cadastrado. '
                  'Cadastre um assistente e atribua duas companhias.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: assistentes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final assistente = assistentes[index];
              final dados = assistente.data();
              final companhias = dados['companhiasResponsaveis'] is List
                  ? List<String>.from(dados['companhiasResponsaveis'])
                  : <String>[];

              return Card(
                color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.groups_outlined),
                  ),
                  title: Text(
                    (assistente['nome'] ?? 'Sem nome').toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    companhias.isEmpty
                        ? 'Duas companhias ainda não foram atribuídas'
                        : companhias.join(' • '),
                  ),
                  isThreeLine: companhias.length > 1,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'editar') {
                        _abrirFormulario(assistente: assistente);
                      } else if (value == 'excluir') {
                        _excluirAssistente(assistente);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'editar',
                        child: Text('Editar atribuições'),
                      ),
                      PopupMenuItem(
                        value: 'excluir',
                        child: Text('Excluir assistente'),
                      ),
                    ],
                  ),
                  onTap: () => _abrirFormulario(assistente: assistente),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
