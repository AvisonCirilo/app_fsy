import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbaJovens extends StatefulWidget {
  const AbaJovens({super.key});

  @override
  State<AbaJovens> createState() => _AbaJovensState();
}

class _AbaJovensState extends State<AbaJovens> {
  // --- VARIÁVEIS DE ESTADO ---
  
  // 1. Linha Verde (Companhia)
  final TextEditingController _companhiaController = TextEditingController();
  bool _editandoCompanhia = false;

  // 2. Linhas Azuis (Consultores): Dados estáticos que virão do Admin depois
  final List<String> _consultores = ["Consultor(a) 1", "Consultor(a) 2"];

  // 3. Linhas Marrons (Jovens): Dados estáticos que virão do Admin depois
  final List<String> _jovens = ["Jovem 1", "Jovem 2", "Jovem 3", "Jovem 4", "Jovem 5"];

  @override
  void initState() {
    super.initState();
    // Assim que a tela abre, procura o nome da companhia na memória
    _carregarNomeCompanhia();
  }

  // --- FUNÇÕES DE MEMÓRIA PARA O NOME DA COMPANHIA ---
  Future<void> _carregarNomeCompanhia() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Se não tiver nada salvo, mostra o texto padrão
      _companhiaController.text = prefs.getString('nomeCompanhia') ?? "Nome da sua Companhia";
    });
  }

  Future<void> _salvarNomeCompanhia(String novoNome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nomeCompanhia', novoNome);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // ==========================================
          // LINHA VERDE: NOME DA COMPANHIA (Editável e com Memória)
          // ==========================================
          Card(
            elevation: 2,
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
                            autofocus: true, // Abre o teclado automaticamente
                            decoration: const InputDecoration(
                              hintText: "Digite o nome da companhia",
                              isDense: true,
                            ),
                            onSubmitted: (novoNome) {
                              setState(() => _editandoCompanhia = false);
                              _salvarNomeCompanhia(novoNome); // Salva na memória
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
                          // Se estava a editar e clicou no certinho, guarda a informação
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
          const SizedBox(height: 25),

          // ==========================================
          // LINHAS AZUIS: CONSULTORES (Do Admin)
          // ==========================================
          const Text(
            "Consultores",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          ..._consultores.map((nome) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(nome),
            ),
          )),
          const SizedBox(height: 25),

          // ==========================================
          // LINHAS MARRONS: JOVENS (Do Admin)
          // ==========================================
          const Text(
            "Jovens da Companhia",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
          ),
          const SizedBox(height: 10),
          ..._jovens.map((nome) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.brown,
                child: Icon(Icons.face, color: Colors.white),
              ),
              title: Text(nome),
            ),
          )),
          
        ],
      ),
    );
  }
}