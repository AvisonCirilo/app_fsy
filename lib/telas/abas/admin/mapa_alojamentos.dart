import 'package:flutter/material.dart';

import '../../../data/app_permissions.dart';
import '../../../data/local_auth_service.dart';
import '../../../data/local_database.dart';
import '../../../data/lodging_structure.dart';

class MapaAlojamentos extends StatefulWidget {
  const MapaAlojamentos({
    super.key,
    this.initialTabIndex = 1,
  });

  final int initialTabIndex;

  @override
  State<MapaAlojamentos> createState() => _MapaAlojamentosState();
}

class _MapaAlojamentosState extends State<MapaAlojamentos> {
  Future<void> _alocarJovem(LocalDocumentSnapshot jovem) async {
    final quartoAtual = (jovem['quarto'] ?? '').toString();
    final andarAtual = LodgingStructure.floorFor(jovem) ?? 1;
    final andaresDisponiveis = <int>{1, 2, 3, andarAtual}.toList()..sort();
    final quartoController = TextEditingController(text: quartoAtual);
    final isEscuro = Theme.of(context).brightness == Brightness.dark;

    final resultado = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        var andarSelecionado = andarAtual;

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
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
                    Row(
                      children: [
                        const Icon(Icons.hotel, color: Colors.indigo, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Alojamento de ${jovem['nome']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Escolha o andar e informe a identificação do quarto.',
                      style: TextStyle(
                        color: isEscuro ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<int>(
                      initialValue: andarSelecionado,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Andar',
                        prefixIcon: Icon(Icons.layers_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: andaresDisponiveis
                          .map(
                            (andar) => DropdownMenuItem(
                              value: andar,
                              child: Text('$andarº andar'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() => andarSelecionado = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: quartoController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Número ou identificação do quarto',
                        hintText: 'Ex.: 101 ou Bloco A - 101',
                        prefixIcon: Icon(Icons.meeting_room_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final quarto = quartoController.text.trim();
                          if (quarto.isEmpty) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Informe o número ou a identificação do quarto.',
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.of(sheetContext).pop({
                            'andar': andarSelecionado,
                            'quarto': quarto,
                          });
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Salvar alojamento'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    quartoController.dispose();

    if (resultado == null || !mounted) return;

    try {
      await LocalDatabase.instance
          .collection('jovens')
          .doc(jovem.id)
          .update({
        'andar': resultado['andar'],
        'quarto': resultado['quarto'],
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${jovem['nome']} foi alocado com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível salvar o alojamento: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _estadoVazio({
    required IconData icone,
    required String titulo,
    required String descricao,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              descricao,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoJovem(
    LocalDocumentSnapshot jovem, {
    bool mostrarStatus = false,
  }) {
    final nome = (jovem['nome'] ?? 'Sem nome').toString();
    final idade = (jovem['idade'] ?? '').toString();
    final companhia = (jovem['companhia'] ?? 'Companhia não informada').toString();
    final quarto = (jovem['quarto'] ?? '').toString().trim();
    final alojado = LodgingStructure.isAssigned(jovem);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      leading: CircleAvatar(
        backgroundColor: alojado
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.orange.withValues(alpha: 0.12),
        child: Icon(
          Icons.person_outline,
          color: alojado ? Colors.green : Colors.orange,
        ),
      ),
      title: Text(
        nome,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        [
          if (idade.isNotEmpty) '$idade anos',
          companhia,
          if (alojado) quarto else 'Sem alojamento',
        ].join(' • '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: mostrarStatus
          ? IconButton(
              tooltip: alojado ? 'Alterar alojamento' : 'Alocar jovem',
              onPressed: () => _alocarJovem(jovem),
              icon: Icon(
                alojado ? Icons.edit_location_alt : Icons.add_location_alt,
                color: Colors.indigo,
              ),
            )
          : null,
    );
  }

  Widget _listaTodosOsJovens(List<LocalDocumentSnapshot> jovens) {
    if (jovens.isEmpty) {
      return _estadoVazio(
        icone: Icons.groups_outlined,
        titulo: 'Nenhum jovem cadastrado',
        descricao: 'Os jovens cadastrados aparecerão nesta lista.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jovens.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) => Card(
        margin: EdgeInsets.zero,
        child: _cartaoJovem(jovens[index], mostrarStatus: true),
      ),
    );
  }

  Widget _listaSemAlojamento(List<LocalDocumentSnapshot> jovens) {
    if (jovens.isEmpty) {
      return _estadoVazio(
        icone: Icons.check_circle_outline,
        titulo: 'Todos os jovens estão alojados!',
        descricao: 'Não há pendências de quartos neste momento.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jovens.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final jovem = jovens[index];
        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: Colors.orange.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              _cartaoJovem(jovem),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _alocarJovem(jovem),
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Definir alojamento'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _hierarquiaPorAndar(List<LodgingFloorGroup> andares) {
    if (andares.isEmpty) {
      return _estadoVazio(
        icone: Icons.meeting_room_outlined,
        titulo: 'Nenhum quarto em uso',
        descricao: 'Quando um jovem receber um quarto, ele aparecerá organizado por andar.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: andares.length,
      itemBuilder: (context, index) {
        final andar = andares[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.withValues(alpha: 0.12),
              child: const Icon(Icons.layers_outlined, color: Colors.indigo),
            ),
            title: Text(
              LodgingStructure.floorLabel(andar.number),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${andar.rooms.length} ${andar.rooms.length == 1 ? 'quarto em uso' : 'quartos em uso'} • ${andar.youthCount} jovens',
            ),
            children: andar.rooms.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Nenhum quarto em uso neste andar.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ]
                : andar.rooms.map((quarto) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: Card(
                        margin: EdgeInsets.zero,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.035)
                            : Colors.grey.shade50,
                        child: ExpansionTile(
                          leading: const Icon(
                            Icons.meeting_room_outlined,
                            color: Colors.teal,
                          ),
                          title: Text(
                            quarto.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${quarto.youth.length} ${quarto.youth.length == 1 ? 'jovem alojado' : 'jovens alojados'}',
                          ),
                          children: quarto.youth
                              .map(
                                (jovem) => _cartaoJovem(
                                  jovem,
                                  mostrarStatus: true,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final permissions = AppPermissions.fromProfile(
      LocalAuthService.instance.currentUser?.profile ?? {},
    );

    if (!permissions.canAccessLodging) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gestão de Alojamentos')),
        body: const Center(
          child: Text(
            'Apenas a Logística e o Administrador podem acessar os alojamentos.',
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTabIndex.clamp(0, 2).toInt(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestão de Alojamentos'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                icon: Icon(Icons.groups_outlined),
                text: 'Todos os jovens',
              ),
              Tab(
                icon: Icon(Icons.layers_outlined),
                text: 'Por andar',
              ),
              Tab(
                icon: Icon(Icons.person_off_outlined),
                text: 'Sem alojamento',
              ),
            ],
          ),
        ),
        body: StreamBuilder<LocalQuerySnapshot>(
          stream: LocalDatabase.instance.collection('jovens').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Não foi possível carregar os jovens.'),
              );
            }

            final jovens = List<LocalDocumentSnapshot>.from(
              snapshot.data?.docs ?? const <LocalDocumentSnapshot>[],
            )..sort(
                (a, b) => (a['nome'] ?? '')
                    .toString()
                    .toLowerCase()
                    .compareTo((b['nome'] ?? '').toString().toLowerCase()),
              );

            final alojados = jovens
                .where(LodgingStructure.isAssigned)
                .toList();
            final semAlojamento = jovens
                .where((jovem) => !LodgingStructure.isAssigned(jovem))
                .toList();
            final andares = LodgingStructure.groupByFloor(alojados);

            return TabBarView(
              children: [
                _listaTodosOsJovens(jovens),
                _hierarquiaPorAndar(andares),
                _listaSemAlojamento(semAlojamento),
              ],
            );
          },
        ),
      ),
    );
  }
}
