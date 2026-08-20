import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListaJovensTela extends StatefulWidget {
  const ListaJovensTela({super.key});

  @override
  State<ListaJovensTela> createState() => _ListaJovensTelaState();
}

class _ListaJovensTelaState extends State<ListaJovensTela> {
  final TextEditingController _pesquisaController = TextEditingController();

  // Lista de Consultores agora vem do Banco de Dados!
  List<String> _consultoresDisponiveis = ["A Definir"];

  String _criterioOrdenacao = 'nome'; 
  bool _ordemCrescente = true; 

  @override
  void initState() {
    super.initState();
    _carregarConsultoresDoBanco();
  }

  // ==========================================
  // LÊ OS UTILIZADORES DO BANCO PARA O MENU SUSPENSO
  // ==========================================
  void _carregarConsultoresDoBanco() {
    FirebaseFirestore.instance.collection('usuarios').snapshots().listen((snapshot) {
      List<String> nomesLideranca = ["A Definir"];
      for (var doc in snapshot.docs) {
        if (doc.data().containsKey('nome')) {
          nomesLideranca.add(doc['nome']);
        }
      }
      if (mounted) {
        setState(() {
          _consultoresDisponiveis = nomesLideranca.toSet().toList(); // Remove nomes repetidos, se houver
        });
      }
    });
  }

  void _abrirPainelFiltros() {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  const Text("Ordenar Lista Por:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 10,
                    children: ['nome', 'idade', 'genero'].map((criterio) {
                      bool isSelecionado = _criterioOrdenacao == criterio;
                      return ChoiceChip(
                        label: Text(criterio.toUpperCase(), style: TextStyle(color: isSelecionado ? Colors.white : (isEscuro ? Colors.white70 : Colors.black87))),
                        selected: isSelecionado,
                        selectedColor: Colors.grey.shade700,
                        backgroundColor: isEscuro ? Colors.grey.shade800 : Colors.grey.shade200,
                        onSelected: (selecionado) {
                          if (selecionado) setStateSheet(() => _criterioOrdenacao = criterio);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  
                  SwitchListTile(
                    title: const Text("Ordem Crescente (A-Z / Menor p/ Maior)", style: TextStyle(fontWeight: FontWeight.bold)),
                    activeColor: Colors.grey.shade700,
                    value: _ordemCrescente,
                    onChanged: (valor) => setStateSheet(() => _ordemCrescente = valor),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        setState(() {}); // Atualiza a tela principal para aplicar filtros
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text("Aplicar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  // ==========================================
  // PAINEL INTELIGENTE (CRIAR E EDITAR NO FIRESTORE)
  // ==========================================
  void _mostrarPainelFormularioJovem({Map<String, dynamic>? jovemAtual}) {
    bool isEdicao = jovemAtual != null;
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    final nomeCtrl = TextEditingController(text: isEdicao ? jovemAtual['nome'] : "");
    final idadeCtrl = TextEditingController(text: isEdicao ? jovemAtual['idade'] : "");
    final saudeCtrl = TextEditingController(text: isEdicao ? jovemAtual['saude'] : "");
    final medicamentoCtrl = TextEditingController(text: isEdicao ? jovemAtual['medicamento'] : "");
    final companhiaCtrl = TextEditingController(text: isEdicao ? jovemAtual['companhia'] : "");
    final quartoCtrl = TextEditingController(text: isEdicao ? jovemAtual['quarto'] : "");
    
    String generoSelecionado = isEdicao ? jovemAtual['genero'] : "Masculino";
    bool membroIgreja = isEdicao ? (jovemAtual['membro'] == true) : true; 
    
    // Verifica se o consultor que está na ficha do jovem ainda existe no banco
    String consultorSelecionado = "A Definir";
    if (isEdicao && jovemAtual['consultor'] != null && _consultoresDisponiveis.contains(jovemAtual['consultor'])) {
      consultorSelecionado = jovemAtual['consultor'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24, 
                left: 24, right: 24, top: 24
              ),
              decoration: BoxDecoration(color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isEdicao ? Icons.edit : Icons.person_add, size: 22, color: Colors.grey.shade700),
                        const SizedBox(width: 10),
                        Text(isEdicao ? "Editar Jovem" : "Novo Jovem", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 25),

                    _construirCampo("Nome Completo", nomeCtrl, Icons.badge, isEscuro),
                    const SizedBox(height: 15),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: generoSelecionado,
                            dropdownColor: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                            style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: "Género",
                              filled: true, fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5)),
                            ),
                            items: ["Masculino", "Feminino"].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                            onChanged: (v) => setStateSheet(() => generoSelecionado = v!),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 2,
                          child: _construirCampo("Idade", idadeCtrl, Icons.cake, isEscuro, tipo: TextInputType.number),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    _construirCampo("Saúde / Restrições (Opcional)", saudeCtrl, Icons.health_and_safety, isEscuro),
                    const SizedBox(height: 15),
                    _construirCampo("Medicamentos (Opcional)", medicamentoCtrl, Icons.medication, isEscuro),
                    const SizedBox(height: 15),

                    const Align(alignment: Alignment.centerLeft, child: Text("Informações de Logística", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _construirCampo("Companhia", companhiaCtrl, Icons.flag, isEscuro)),
                        const SizedBox(width: 15),
                        Expanded(child: _construirCampo("Quarto", quartoCtrl, Icons.hotel, isEscuro)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    DropdownButtonFormField<String>(
                      value: consultorSelecionado,
                      dropdownColor: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                      style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                      decoration: InputDecoration(
                        labelText: "Consultor Responsável",
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        filled: true, fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5)),
                        prefixIcon: Icon(Icons.supervisor_account, color: Colors.grey.shade700, size: 20),
                      ),
                      items: _consultoresDisponiveis.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setStateSheet(() => consultorSelecionado = v!),
                    ),
                    const SizedBox(height: 15),

                    Container(
                      decoration: BoxDecoration(color: isEscuro ? Colors.black26 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: SwitchListTile(
                        title: const Text("Membro da Igreja?", style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(membroIgreja ? "Sim" : "Não", style: TextStyle(color: membroIgreja ? Colors.green : Colors.grey)),
                        activeColor: Colors.grey.shade700,
                        secondary: Icon(Icons.church, color: membroIgreja ? Colors.grey.shade700 : Colors.grey),
                        value: membroIgreja,
                        onChanged: (valor) => setStateSheet(() => membroIgreja = valor),
                      ),
                    ),
                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () async {
                          if (nomeCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("O nome é obrigatório!"), backgroundColor: Colors.redAccent));
                            return;
                          }
                          
                          Navigator.pop(context); // Fecha o painel primeiro
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Salvando jovem..."), backgroundColor: Colors.grey.shade700));

                          // DADOS PARA GRAVAR NO FIRESTORE
                          Map<String, dynamic> dadosJovem = {
                            "nome": nomeCtrl.text,
                            "idade": idadeCtrl.text.isEmpty ? "0" : idadeCtrl.text,
                            "genero": generoSelecionado,
                            "saude": saudeCtrl.text.isEmpty ? "Nenhuma" : saudeCtrl.text,
                            "medicamento": medicamentoCtrl.text,
                            "companhia": companhiaCtrl.text.isEmpty ? "A Definir" : companhiaCtrl.text,
                            "quarto": quartoCtrl.text,
                            "membro": membroIgreja,
                            "consultor": consultorSelecionado,
                          };

                          try {
                            if (isEdicao) {
                              await FirebaseFirestore.instance.collection('jovens').doc(jovemAtual['id']).update(dadosJovem);
                            } else {
                              dadosJovem['criadoEm'] = FieldValue.serverTimestamp();
                              await FirebaseFirestore.instance.collection('jovens').add(dadosJovem);
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Jovem ${isEdicao ? 'atualizado' : 'cadastrado'}!"), backgroundColor: Colors.green));
                            }
                          } catch (e) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.redAccent));
                          }
                        },
                        icon: const Icon(Icons.save, size: 20),
                        label: Text(isEdicao ? "Atualizar Jovem" : "Salvar Jovem", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _construirCampo(String label, TextEditingController controller, IconData icone, bool isEscuro, {TextInputType tipo = TextInputType.text}) {
    return TextField(
      controller: controller, keyboardType: tipo,
      style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: Colors.grey.shade700),
        prefixIcon: Icon(icone, color: Colors.grey.shade700, size: 20),
        filled: true, fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5)),
      ),
    );
  }

  void _mostrarFichaJovem(Map<String, dynamic> jovem, bool isEscuro) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: jovem['genero'] == 'Masculino' ? Colors.blue.shade100 : Colors.pink.shade100,
                    child: Icon(Icons.face, size: 35, color: jovem['genero'] == 'Masculino' ? Colors.blue : Colors.pink),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(jovem['nome'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("${jovem['idade']} anos • ${jovem['companhia']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                        if(jovem['quarto'].isNotEmpty) 
                          Text("Quarto: ${jovem['quarto']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
              
              _construirLinhaDetalhe(Icons.supervisor_account, "Consultor Responsável", jovem['consultor'] ?? "A Definir"),
              const SizedBox(height: 10),
              
              _construirLinhaDetalhe(Icons.church, "Membro da Igreja", jovem['membro'] ? "Sim" : "Não"),
              const SizedBox(height: 10),
              _construirLinhaDetalhe(Icons.health_and_safety, "Saúde / Restrições", jovem['saude'], alerta: jovem['saude'] != "Nenhuma"),
              const SizedBox(height: 10),
              _construirLinhaDetalhe(Icons.medication, "Medicamentos", jovem['medicamento'].isEmpty ? "Nenhum" : jovem['medicamento'], alerta: jovem['medicamento'].isNotEmpty),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Fechar Ficha", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _construirLinhaDetalhe(IconData icone, String titulo, String valor, {bool alerta = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: alerta ? Colors.redAccent : Colors.grey.shade600, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              Text(valor, style: TextStyle(fontSize: 16, color: alerta ? Colors.redAccent : null, fontWeight: alerta ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Jovens"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarPainelFormularioJovem(),
        backgroundColor: Colors.grey.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add, size: 20),
        label: const Text("Novo", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pesquisaController,
                    onChanged: (valor) => setState(() {}), // Atualiza a tela para rodar o StreamBuilder novamente
                    decoration: InputDecoration(
                      hintText: "Pesquisar por nome...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade700),
                      suffixIcon: _pesquisaController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey.shade700),
                              onPressed: () {
                                _pesquisaController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true, fillColor: isEscuro ? Colors.black26 : Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16), 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 10), 
                Container(
                  height: 52, 
                  width: 52,
                  decoration: BoxDecoration(
                    color: isEscuro ? Colors.black26 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.tune, color: Colors.grey.shade700), 
                    tooltip: "Organizar e Filtrar",
                    onPressed: _abrirPainelFiltros,
                  ),
                ),
              ],
            ),
          ),
          
          // ==========================================
          // A MÁGICA EM TEMPO REAL
          // ==========================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('jovens').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.grey));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text("Nenhum jovem cadastrado.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      ],
                    ),
                  );
                }

                // 1. Pega os dados do Firestore e converte para a nossa lista local
                List<Map<String, dynamic>> listaLocal = snapshot.data!.docs.map((doc) {
                  var dados = doc.data() as Map<String, dynamic>;
                  dados['id'] = doc.id; // Guarda o ID único do Firebase
                  return dados;
                }).toList();

                // 2. Aplica a Pesquisa por Texto
                String textoBusca = _pesquisaController.text.toLowerCase();
                if (textoBusca.isNotEmpty) {
                  listaLocal = listaLocal.where((j) => j['nome'].toString().toLowerCase().contains(textoBusca)).toList();
                }

                // 3. Aplica a Ordenação (Nome, Idade, Gênero)
                listaLocal.sort((a, b) {
                  int comparacao = 0;
                  if (_criterioOrdenacao == 'nome') {
                    comparacao = a['nome'].toString().compareTo(b['nome'].toString());
                  } else if (_criterioOrdenacao == 'idade') {
                    int idadeA = int.tryParse(a['idade'].toString()) ?? 0;
                    int idadeB = int.tryParse(b['idade'].toString()) ?? 0;
                    comparacao = idadeA.compareTo(idadeB);
                  } else if (_criterioOrdenacao == 'genero') {
                    comparacao = a['genero'].toString().compareTo(b['genero'].toString());
                  }
                  return _ordemCrescente ? comparacao : -comparacao;
                });

                if (listaLocal.isEmpty) {
                  return const Center(child: Text("Nenhum resultado para a pesquisa."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                  itemCount: listaLocal.length,
                  itemBuilder: (context, index) {
                    final jovem = listaLocal[index];
                    bool temAlertaMedico = (jovem['saude'] != "Nenhuma") || (jovem['medicamento'] != "");

                    return Dismissible(
                      key: ValueKey(jovem['id']), // ID ÚNICO GARANTE QUE O FLUTTER NÃO SE PERDE!
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.delete, color: Colors.white, size: 30),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.edit, color: Colors.white, size: 30),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          _mostrarPainelFormularioJovem(jovemAtual: jovem);
                          return false; // Retorna false para não apagar visualmente
                        } else if (direction == DismissDirection.startToEnd) {
                          bool confirmar = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Row(
                                  children: [Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28), SizedBox(width: 10), Text("Excluir Jovem")],
                                ),
                                content: Text("Tem a certeza que deseja excluir ${jovem['nome']}?", style: const TextStyle(fontSize: 15)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                    onPressed: () => Navigator.of(context).pop(true), 
                                    child: const Text("Excluir", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              );
                            },
                          ) ?? false;

                          if (confirmar) {
                            // APAGA NO BANCO DE DADOS
                            await FirebaseFirestore.instance.collection('jovens').doc(jovem['id']).delete();
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${jovem['nome']} foi removido."), backgroundColor: Colors.redAccent));
                            return true; // Deixa o Dismissible terminar a animação
                          }
                          return false;
                        }
                        return false;
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: jovem['genero'] == 'Masculino' ? Colors.blue.withOpacity(0.2) : Colors.pink.withOpacity(0.2),
                            child: Text(
                              jovem['nome'][0].toUpperCase(),
                              style: TextStyle(color: jovem['genero'] == 'Masculino' ? Colors.blue : Colors.pink, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(jovem['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${jovem['idade']} anos • ${jovem['companhia']}"),
                          trailing: temAlertaMedico
                              ? const Icon(Icons.medical_services, color: Colors.redAccent, size: 22)
                              : const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                          onTap: () => _mostrarFichaJovem(jovem, isEscuro),
                        ),
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}