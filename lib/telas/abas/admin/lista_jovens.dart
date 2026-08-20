import 'package:flutter/material.dart';

class ListaJovensTela extends StatefulWidget {
  const ListaJovensTela({super.key});

  @override
  State<ListaJovensTela> createState() => _ListaJovensTelaState();
}

class _ListaJovensTelaState extends State<ListaJovensTela> {
  final TextEditingController _pesquisaController = TextEditingController();

  // Lista simulada de Consultores disponíveis no sistema
  final List<String> _consultoresDisponiveis = [
    "A Definir",
    "Maria Consultora",
    "João Consultor",
    "Pedro Silva",
    "Lucas Souza"
  ];

  // Simulação do Banco de Dados de Jovens (AGORA COM CONSULTOR RESPONSÁVEL)
  final List<Map<String, dynamic>> _todosOsJovens = [
    {"nome": "Ana Clara Souza", "idade": "16", "genero": "Feminino", "membro": true, "saude": "Nenhuma", "medicamento": "", "companhia": "Cia 3", "quarto": "", "consultor": "Maria Consultora"},
    {"nome": "Bruno Costa", "idade": "15", "genero": "Masculino", "membro": false, "saude": "Asma", "medicamento": "Bombinha (Salbutamol)", "companhia": "Cia 1", "quarto": "B-201", "consultor": "João Consultor"},
    {"nome": "Camila Alves", "idade": "17", "genero": "Feminino", "membro": true, "saude": "Intolerância à Lactose", "medicamento": "", "companhia": "Cia 2", "quarto": "", "consultor": "A Definir"},
    {"nome": "Diego Fernandes", "idade": "14", "genero": "Masculino", "membro": true, "saude": "Nenhuma", "medicamento": "", "companhia": "Cia 4", "quarto": "B-205", "consultor": "Maria Consultora"},
    {"nome": "Eduardo Lima", "idade": "16", "genero": "Masculino", "membro": true, "saude": "TDAH", "medicamento": "Ritalina", "companhia": "Cia 1", "quarto": "", "consultor": "João Consultor"},
    {"nome": "Fernanda Ribeiro", "idade": "15", "genero": "Feminino", "membro": true, "saude": "Nenhuma", "medicamento": "", "companhia": "Cia 2", "quarto": "", "consultor": "A Definir"},
  ];

  List<Map<String, dynamic>> _jovensFiltrados = [];
  String _criterioOrdenacao = 'nome'; 
  bool _ordemCrescente = true; 

  @override
  void initState() {
    super.initState();
    _aplicarFiltrosEOrdenacao();
  }

  void _aplicarFiltrosEOrdenacao() {
    setState(() {
      String texto = _pesquisaController.text.toLowerCase();
      if (texto.isEmpty) {
        _jovensFiltrados = List.from(_todosOsJovens);
      } else {
        _jovensFiltrados = _todosOsJovens
            .where((jovem) => jovem['nome'].toLowerCase().contains(texto))
            .toList();
      }

      _jovensFiltrados.sort((a, b) {
        int comparacao = 0;
        if (_criterioOrdenacao == 'nome') {
          comparacao = a['nome'].compareTo(b['nome']);
        } else if (_criterioOrdenacao == 'idade') {
          int idadeA = int.tryParse(a['idade']) ?? 0;
          int idadeB = int.tryParse(b['idade']) ?? 0;
          comparacao = idadeA.compareTo(idadeB);
        } else if (_criterioOrdenacao == 'genero') {
          comparacao = a['genero'].compareTo(b['genero']);
        }
        return _ordemCrescente ? comparacao : -comparacao;
      });
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
                        _aplicarFiltrosEOrdenacao();
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
    
    // Controle do Consultor Selecionado
    String consultorSelecionado = isEdicao ? (jovemAtual['consultor'] ?? "A Definir") : "A Definir";

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
                    
                    // =====================================
                    // CAMPO PARA ESCOLHER O CONSULTOR
                    // =====================================
                    DropdownButtonFormField<String>(
                      value: _consultoresDisponiveis.contains(consultorSelecionado) ? consultorSelecionado : "A Definir",
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
                        onPressed: () {
                          if (nomeCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("O nome é obrigatório!"), backgroundColor: Colors.redAccent));
                            return;
                          }
                          setState(() {
                            if (isEdicao) {
                              jovemAtual['nome'] = nomeCtrl.text;
                              jovemAtual['idade'] = idadeCtrl.text;
                              jovemAtual['genero'] = generoSelecionado;
                              jovemAtual['saude'] = saudeCtrl.text.isEmpty ? "Nenhuma" : saudeCtrl.text;
                              jovemAtual['medicamento'] = medicamentoCtrl.text;
                              jovemAtual['companhia'] = companhiaCtrl.text;
                              jovemAtual['quarto'] = quartoCtrl.text;
                              jovemAtual['membro'] = membroIgreja;
                              jovemAtual['consultor'] = consultorSelecionado; // Salva o consultor
                            } else {
                              _todosOsJovens.add({
                                "nome": nomeCtrl.text,
                                "idade": idadeCtrl.text.isEmpty ? "0" : idadeCtrl.text,
                                "genero": generoSelecionado,
                                "saude": saudeCtrl.text.isEmpty ? "Nenhuma" : saudeCtrl.text,
                                "medicamento": medicamentoCtrl.text,
                                "companhia": companhiaCtrl.text.isEmpty ? "A Definir" : companhiaCtrl.text,
                                "quarto": quartoCtrl.text,
                                "membro": membroIgreja,
                                "consultor": consultorSelecionado, // Salva o consultor
                              });
                            }
                            _aplicarFiltrosEOrdenacao(); 
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Jovem ${isEdicao ? 'atualizado' : 'cadastrado'}!"), backgroundColor: Colors.grey.shade700));
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
              
              // NOVO: Mostra de quem o jovem é!
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
                    onChanged: (valor) => _aplicarFiltrosEOrdenacao(),
                    decoration: InputDecoration(
                      hintText: "Pesquisar por nome...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade700),
                      suffixIcon: _pesquisaController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey.shade700),
                              onPressed: () {
                                _pesquisaController.clear();
                                _aplicarFiltrosEOrdenacao();
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
          
          Expanded(
            child: _jovensFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text("Nenhum jovem encontrado.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                    itemCount: _jovensFiltrados.length,
                    itemBuilder: (context, index) {
                      final jovem = _jovensFiltrados[index];
                      bool temAlertaMedico = (jovem['saude'] != "Nenhuma") || (jovem['medicamento'] != "");

                      return Dismissible(
                        key: ValueKey(jovem['nome']), 
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
                            return false; 
                          } else if (direction == DismissDirection.startToEnd) {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                                      SizedBox(width: 10),
                                      Text("Excluir Jovem"),
                                    ],
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
                            );
                          }
                          return false;
                        },
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            setState(() {
                              _todosOsJovens.remove(jovem); 
                              _aplicarFiltrosEOrdenacao(); 
                            });
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: jovem['genero'] == 'Masculino' ? Colors.blue.withOpacity(0.2) : Colors.pink.withOpacity(0.2),
                              child: Text(
                                jovem['nome'][0],
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
                  ),
          ),
        ],
      ),
    );
  }
}