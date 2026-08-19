import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbaCompanhia extends StatefulWidget {
  const AbaCompanhia({super.key});

  @override
  State<AbaCompanhia> createState() => _AbaCompanhiaState(); 
}

class _AbaCompanhiaState extends State<AbaCompanhia> {
  // --- VARIÁVEIS DE ESTADO ---
  
  // 1. Linha Verde (Companhia)
  final TextEditingController _companhiaController = TextEditingController();
  bool _editandoCompanhia = false;

  // 2. Metas da Companhia
  List<Map<String, dynamic>> _metas = [];

  // 3. Linhas Azuis (Consultores): Dados estáticos
  final List<String> _consultores = ["Consultor(a) 1", "Consultor(a) 2"];

  // 4. Linhas Marrons (Jovens): Dados estáticos
  final List<String> _jovens = ["Jovem 1", "Jovem 2", "Jovem 3", "Jovem 4", "Jovem 5"];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  // --- FUNÇÕES DE MEMÓRIA ---
  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // A MÁGICA ACONTECE AQUI: A chave 'perfil_companhia' é a mesma usada na aba Perfil!
      _companhiaController.text = prefs.getString('perfil_companhia') ?? "Nome da sua Companhia";
      
      // Carrega as metas guardadas
      String? metasJson = prefs.getString('companhia_metas');
      if (metasJson != null) {
        _metas = List<Map<String, dynamic>>.from(jsonDecode(metasJson));
      }
    });
  }

  Future<void> _salvarNomeCompanhia(String novoNome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('perfil_companhia', novoNome); // Guarda na mesma chave do perfil
  }

  Future<void> _salvarMetas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('companhia_metas', jsonEncode(_metas));
  }

  // --- LÓGICA DAS METAS ---
  void _mostrarDialogoNovaMeta() {
    final TextEditingController novaMetaController = TextEditingController();
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.flag, color: Colors.teal),
              SizedBox(width: 10),
              Text("Nova Meta", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: TextField(
            controller: novaMetaController,
            autofocus: true,
            maxLines: 3,
            style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: "Ex: Todos os jovens lerem as escrituras antes de dormir...",
              hintStyle: TextStyle(color: isEscuro ? Colors.white30 : Colors.black38),
              filled: true,
              fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (novaMetaController.text.trim().isNotEmpty) {
                  setState(() {
                    _metas.add({
                      "texto": novaMetaController.text.trim(),
                      "concluido": false,
                    });
                  });
                  _salvarMetas();
                  Navigator.pop(context);
                }
              },
              child: const Text("Adicionar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _alternarMeta(int index, bool concluido) {
    setState(() {
      _metas[index]["concluido"] = concluido;
    });
    _salvarMetas();
  }

  void _removerMeta(int index) {
    setState(() {
      _metas.removeAt(index);
    });
    _salvarMetas();
  }

  @override
  Widget build(BuildContext context) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;
    Color corTextoSecundario = isEscuro ? Colors.white70 : Colors.black54;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // ==========================================
          // LINHA VERDE: NOME DA COMPANHIA
          // ==========================================
          Card(
            elevation: 2,
            color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Colors.green, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _editandoCompanhia
                        ? TextField(
                            controller: _companhiaController,
                            autofocus: true,
                            style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              hintText: "Digite o nome da companhia",
                              hintStyle: TextStyle(color: isEscuro ? Colors.white54 : Colors.black38),
                              isDense: true,
                            ),
                            onSubmitted: (novoNome) {
                              setState(() => _editandoCompanhia = false);
                              _salvarNomeCompanhia(novoNome);
                            },
                          )
                        : Text(
                            _companhiaController.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green, 
                            ),
                          ),
                  ),
                  IconButton(
                    icon: Icon(
                      _editandoCompanhia ? Icons.check_circle : Icons.edit,
                      color: _editandoCompanhia ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_editandoCompanhia) {
                          _salvarNomeCompanhia(_companhiaController.text);
                        }
                        _editandoCompanhia = !_editandoCompanhia;
                      });
                    },
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // ==========================================
          // METAS DA COMPANHIA (Checklist)
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.track_changes, color: Colors.teal),
                  SizedBox(width: 8),
                  Text("Metas da Companhia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.teal, size: 28),
                onPressed: _mostrarDialogoNovaMeta,
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          if (_metas.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
              ),
              child: const Center(
                child: Text(
                  "Nenhuma meta definida ainda.\nClique no botão '+' para adicionar.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            )
          else
            ...List.generate(_metas.length, (index) {
              bool isConcluido = _metas[index]["concluido"];
              return Dismissible(
                key: Key(_metas[index]["texto"] + index.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) => _removerMeta(index),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200),
                  ),
                  child: CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    activeColor: Colors.teal,
                    checkColor: Colors.white,
                    title: Text(
                      _metas[index]["texto"],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isConcluido ? FontWeight.normal : FontWeight.w500,
                        color: isConcluido ? corTextoSecundario : (isEscuro ? Colors.white : Colors.black87),
                        decoration: isConcluido ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                    value: isConcluido,
                    onChanged: (bool? valor) => _alternarMeta(index, valor ?? false),
                  ),
                ),
              );
            }),
          const SizedBox(height: 30),

          // ==========================================
          // LINHAS AZUIS: CONSULTORES
          // ==========================================
          const Text("Consultores", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          ..._consultores.map((nome) => Card(
            elevation: 0,
            color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
              title: Text(nome, style: TextStyle(color: isEscuro ? Colors.white : Colors.black87)),
            ),
          )),
          const SizedBox(height: 25),

          // ==========================================
          // LINHAS MARRONS: JOVENS
          // ==========================================
          const Text("Jovens da Companhia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
          const SizedBox(height: 10),
          ..._jovens.map((nome) => Card(
            elevation: 0,
            color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.brown, child: Icon(Icons.face, color: Colors.white)),
              title: Text(nome, style: TextStyle(color: isEscuro ? Colors.white : Colors.black87)),
            ),
          )),
          
        ],
      ),
    );
  }
}