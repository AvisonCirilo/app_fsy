import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AbaCompanhia extends StatefulWidget {
  const AbaCompanhia({super.key});

  @override
  State<AbaCompanhia> createState() => _AbaCompanhiaState();
}

class _AbaCompanhiaState extends State<AbaCompanhia> {
  // --- VARIÁVEIS DE ESTADO ---
  final TextEditingController _companhiaController = TextEditingController();
  bool _editandoCompanhia = false;
  String _companhiaAtual = "Carregando...";

  @override
  void initState() {
    super.initState();
    _carregarDadosLocais();
  }

  // Puxa a companhia que está salva no aparelho
  Future<void> _carregarDadosLocais() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _companhiaAtual = prefs.getString('perfil_companhia') ?? "A Definir";
      _companhiaController.text = _companhiaAtual;
    });
  }

  // Atualiza a companhia localmente E no Firebase!
  Future<void> _salvarNomeCompanhia(String novoNome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('perfil_companhia', novoNome); 
    
    setState(() {
      _companhiaAtual = novoNome;
    });

    User? usuarioLogado = FirebaseAuth.instance.currentUser;
    if (usuarioLogado != null) {
      try {
        await FirebaseFirestore.instance.collection('usuarios').doc(usuarioLogado.uid).update({
          'companhia': novoNome,
        });
      } catch (e) {
        debugPrint("Erro ao atualizar companhia no banco: $e");
      }
    }
  }

  // ==========================================
  // LÓGICA DE METAS PARTILHADAS (FIREBASE)
  // ==========================================
  void _mostrarDialogoNovaMeta(String ciaDocId, List metasAtuais) {
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
              filled: true, fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                if (novaMetaController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  
                  // Adiciona a nova meta à lista existente e envia pro Firebase
                  metasAtuais.add({
                    "texto": novaMetaController.text.trim(),
                    "concluido": false,
                  });
                  await FirebaseFirestore.instance.collection('companhias').doc(ciaDocId).update({
                    'metas': metasAtuais
                  });
                }
              },
              child: const Text("Adicionar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _alternarMeta(String ciaDocId, List metasAtuais, int index, bool concluido) async {
    metasAtuais[index]["concluido"] = concluido;
    await FirebaseFirestore.instance.collection('companhias').doc(ciaDocId).update({'metas': metasAtuais});
  }

  Future<void> _removerMeta(String ciaDocId, List metasAtuais, int index) async {
    metasAtuais.removeAt(index);
    await FirebaseFirestore.instance.collection('companhias').doc(ciaDocId).update({'metas': metasAtuais});
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
            elevation: 2, color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
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
                        : Text(_companhiaAtual, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                  IconButton(
                    icon: Icon(_editandoCompanhia ? Icons.check_circle : Icons.edit, color: _editandoCompanhia ? Colors.green : Colors.grey),
                    onPressed: () {
                      setState(() {
                        if (_editandoCompanhia) _salvarNomeCompanhia(_companhiaController.text);
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
          // METAS DA COMPANHIA (Checklist via Firestore)
          // ==========================================
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('companhias').where('nome', isEqualTo: _companhiaAtual).limit(1).snapshots(),
            builder: (context, snapshot) {
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.teal));
              }

              // Se a companhia ainda não foi criada no painel do Admin, mostra um aviso
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.track_changes, color: Colors.teal), SizedBox(width: 8),
                        Text("Metas da Companhia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.teal.withValues(alpha: 0.3))),
                      child: const Text("Companhia não encontrada no sistema. Peça ao Administrador para criar esta companhia no painel 'Gerenciar Companhias'.", textAlign: TextAlign.center, style: TextStyle(color: Colors.teal)),
                    ),
                  ],
                );
              }

              // Apanha o documento da companhia
              var ciaDoc = snapshot.data!.docs.first;
              List metas = (ciaDoc.data() as Map).containsKey('metas') ? ciaDoc['metas'] : [];

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.track_changes, color: Colors.teal), SizedBox(width: 8),
                          Text("Metas da Companhia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.teal, size: 28),
                        onPressed: () => _mostrarDialogoNovaMeta(ciaDoc.id, metas),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (metas.isEmpty)
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.teal.withValues(alpha: 0.3))),
                      child: const Text("Nenhuma meta definida ainda.\nClique no botão '+' para adicionar.", textAlign: TextAlign.center, style: TextStyle(color: Colors.teal)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: metas.length,
                      itemBuilder: (context, index) {
                        bool isConcluido = metas[index]["concluido"];
                        return Dismissible(
                          key: ValueKey(metas[index]["texto"] + index.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) => _removerMeta(ciaDoc.id, metas, index),
                          background: Container(
                            alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 8), elevation: 0, color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)),
                            child: CheckboxListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              activeColor: Colors.teal, checkColor: Colors.white,
                              title: Text(
                                metas[index]["texto"],
                                style: TextStyle(
                                  fontSize: 15, fontWeight: isConcluido ? FontWeight.normal : FontWeight.w500,
                                  color: isConcluido ? corTextoSecundario : (isEscuro ? Colors.white : Colors.black87),
                                  decoration: isConcluido ? TextDecoration.lineThrough : TextDecoration.none,
                                ),
                              ),
                              value: isConcluido,
                              onChanged: (bool? valor) => _alternarMeta(ciaDoc.id, metas, index, valor ?? false),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            }
          ),
          const SizedBox(height: 30),

          // ==========================================
          // LINHAS AZUIS: CONSULTORES DO BANCO
          // ==========================================
          const Text("Equipa de Liderança", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('usuarios').where('companhia', isEqualTo: _companhiaAtual).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(color: Colors.blue);
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("Nenhum líder associado a esta companhia.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
              
              return ListView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var user = snapshot.data!.docs[index];
                  return Card(
                    elevation: 0, color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white, margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)),
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                      title: Text(user['nome'], style: TextStyle(color: isEscuro ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                      subtitle: Text(user['funcao'], style: TextStyle(color: corTextoSecundario, fontSize: 12)),
                    ),
                  );
                },
              );
            }
          ),
          const SizedBox(height: 25),

          // ==========================================
          // LINHAS MARRONS: JOVENS DO BANCO
          // ==========================================
          const Text("Jovens da Companhia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('jovens').where('companhia', isEqualTo: _companhiaAtual).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(color: Colors.brown);
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("Nenhum jovem associado a esta companhia.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
              
              return ListView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var jovem = snapshot.data!.docs[index];
                  return Card(
                    elevation: 0, color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white, margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.brown, child: Text(jovem['nome'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      title: Text(jovem['nome'], style: TextStyle(color: isEscuro ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                      subtitle: Text("${jovem['idade']} anos", style: TextStyle(color: corTextoSecundario, fontSize: 12)),
                    ),
                  );
                },
              );
            }
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}