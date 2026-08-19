import 'package:flutter/material.dart';

class ListaJovensTela extends StatefulWidget {
  const ListaJovensTela({super.key});

  @override
  State<ListaJovensTela> createState() => _ListaJovensTelaState();
}

class _ListaJovensTelaState extends State<ListaJovensTela> {
  final TextEditingController _pesquisaController = TextEditingController();

  // Simulação do Banco de Dados de Jovens
  final List<Map<String, dynamic>> _todosOsJovens = [
    {"nome": "Ana Clara Souza", "idade": "16", "genero": "Feminino", "membro": "Sim", "saude": "Nenhuma", "medicamento": "", "companhia": "Cia 3"},
    {"nome": "Bruno Costa", "idade": "15", "genero": "Masculino", "membro": "Não", "saude": "Asma", "medicamento": "Bombinha (Salbutamol)", "companhia": "Cia 1"},
    {"nome": "Camila Alves", "idade": "17", "genero": "Feminino", "membro": "Sim", "saude": "Intolerância à Lactose", "medicamento": "", "companhia": "Cia 2"},
    {"nome": "Diego Fernandes", "idade": "14", "genero": "Masculino", "membro": "Sim", "saude": "Nenhuma", "medicamento": "", "companhia": "Cia 4"},
    {"nome": "Eduardo Lima", "idade": "16", "genero": "Masculino", "membro": "Sim", "saude": "TDAH", "medicamento": "Ritalina", "companhia": "Cia 1"},
    {"nome": "Fernanda Ribeiro", "idade": "15", "genero": "Feminino", "membro": "Sim", "saude": "Nenhuma", "medicamento": "", "companhia": "Cia 2"},
  ];

  List<Map<String, dynamic>> _jovensFiltrados = [];

  @override
  void initState() {
    super.initState();
    // 1. Organiza a lista original de A-Z
    _todosOsJovens.sort((a, b) => a['nome'].compareTo(b['nome']));
    // 2. Inicia a lista filtrada com todos os jovens
    _jovensFiltrados = List.from(_todosOsJovens);
  }

  // Função que roda sempre que digitamos algo na barra de pesquisa
  void _filtrarLista(String texto) {
    setState(() {
      if (texto.isEmpty) {
        _jovensFiltrados = List.from(_todosOsJovens);
      } else {
        _jovensFiltrados = _todosOsJovens
            .where((jovem) => jovem['nome'].toLowerCase().contains(texto.toLowerCase()))
            .toList();
      }
    });
  }

  // Painel com a "Ficha Completa" ao clicar no jovem
  void _mostrarFichaJovem(Map<String, dynamic> jovem, bool isEscuro) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
              
              _construirLinhaDetalhe(Icons.church, "Membro da Igreja", jovem['membro']),
              const SizedBox(height: 10),
              _construirLinhaDetalhe(Icons.health_and_safety, "Saúde / Restrições", jovem['saude'], alerta: jovem['saude'] != "Nenhuma"),
              const SizedBox(height: 10),
              _construirLinhaDetalhe(Icons.medication, "Medicamentos", jovem['medicamento'].isEmpty ? "Nenhum" : jovem['medicamento'], alerta: jovem['medicamento'].isNotEmpty),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
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
      body: Column(
        children: [
          // ==========================================
          // BARRA DE PESQUISA (Search Bar)
          // ==========================================
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _pesquisaController,
              onChanged: _filtrarLista,
              decoration: InputDecoration(
                hintText: "Pesquisar por nome...",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade700),
                suffixIcon: _pesquisaController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade700),
                        onPressed: () {
                          _pesquisaController.clear();
                          _filtrarLista('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isEscuro ? Colors.black26 : Colors.grey.shade200,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5)),
              ),
            ),
          ),

          // ==========================================
          // LISTA DE JOVENS RESULTANTE
          // ==========================================
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _jovensFiltrados.length,
                    itemBuilder: (context, index) {
                      final jovem = _jovensFiltrados[index];
                      // Verifica se tem problema de saúde ou remédio para acionar o alerta vermelho
                      bool temAlertaMedico = (jovem['saude'] != "Nenhuma") || (jovem['medicamento'] != "");

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: jovem['genero'] == 'Masculino' ? Colors.blue.withOpacity(0.2) : Colors.pink.withOpacity(0.2),
                            child: Text(
                              jovem['nome'][0], // Pega a primeira letra do nome
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}