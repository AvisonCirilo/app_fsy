import 'package:flutter/material.dart';

class AbaInicio extends StatefulWidget {
  const AbaInicio({super.key});

  @override
  State<AbaInicio> createState() => _AbaInicioState();
}

class _AbaInicioState extends State<AbaInicio> {
  // --- VARIÁVEIS DE ESTADO ---
  
  // 1. Linha Verde (Companhia): Controlador para o consultor editar o nome
  final TextEditingController _companhiaController = TextEditingController(text: "Nome da sua Companhia");
  bool _editandoCompanhia = false;

  // 2. Linhas Azuis (Consultores): Dados estáticos que virão do Admin depois
  final List<String> _consultores = ["Consultor(a) 1", "Consultor(a) 2"];

  // 3. Linhas Marrons (Jovens): Dados estáticos que virão do Admin depois
  final List<String> _jovens = ["Jovem 1", "Jovem 2", "Jovem 3", "Jovem 4", "Jovem 5"];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // ==========================================
          // LINHA VERDE: NOME DA COMPANHIA (Editável)
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
                    // Se o botão de editar foi clicado, mostra a caixa de texto. Se não, mostra apenas o texto.
                    child: _editandoCompanhia
                        ? TextField(
                            controller: _companhiaController,
                            decoration: const InputDecoration(
                              hintText: "Digite o nome da companhia",
                              isDense: true,
                            ),
                            // Quando apertar "Enter" no teclado, salva e fecha a edição
                            onSubmitted: (novoNome) {
                              setState(() => _editandoCompanhia = false);
                            },
                          )
                        : Text(
                            _companhiaController.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green, // Cor baseada no seu desenho
                            ),
                          ),
                  ),
                  // Botão de Lápis / Check para editar
                  IconButton(
                    icon: Icon(
                      _editandoCompanhia ? Icons.check_circle : Icons.edit,
                      color: _editandoCompanhia ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
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
          // Esse "map" percorre nossa lista e cria um "cartão" para cada consultor automaticamente
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
          // Cria um cartão para cada jovem na lista
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