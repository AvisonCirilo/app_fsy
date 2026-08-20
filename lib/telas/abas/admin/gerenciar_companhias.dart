import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GerenciarCompanhias extends StatefulWidget {
  const GerenciarCompanhias({super.key});

  @override
  State<GerenciarCompanhias> createState() => _GerenciarCompanhiasState();
}

class _GerenciarCompanhiasState extends State<GerenciarCompanhias> {

  // ==========================================
  // PAINEL PARA CRIAR/EDITAR NOME DA COMPANHIA
  // ==========================================
  void _mostrarPainelCompanhia({DocumentSnapshot? ciaAtual}) {
    bool isEdicao = ciaAtual != null;
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;
    final nomeCtrl = TextEditingController(text: isEdicao ? ciaAtual['nome'] : "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24, 
            left: 24, right: 24, top: 24
          ),
          decoration: BoxDecoration(
            color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isEdicao ? Icons.edit : Icons.flag, size: 28, color: Colors.deepPurple),
                  const SizedBox(width: 10),
                  Text(isEdicao ? "Editar Companhia" : "Nova Companhia", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 25),

              TextField(
                controller: nomeCtrl,
                autofocus: true,
                style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: "Nome da Companhia (Ex: Cia 1)",
                  prefixIcon: const Icon(Icons.flag, color: Colors.deepPurple),
                  filled: true, fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (nomeCtrl.text.isEmpty) return;

                    Navigator.pop(context);

                    try {
                      if (isEdicao) {
                        await FirebaseFirestore.instance.collection('companhias').doc(ciaAtual.id).update({'nome': nomeCtrl.text});
                      } else {
                        await FirebaseFirestore.instance.collection('companhias').add({
                          'nome': nomeCtrl.text,
                          'criadoEm': FieldValue.serverTimestamp(),
                        });
                      }
                      // ignore: use_build_context_synchronously
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Companhia salva com sucesso!"), backgroundColor: Colors.green));
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.redAccent));
                    }
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(isEdicao ? "Atualizar" : "Criar Companhia", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // PAINEL PARA VER QUEM ESTÁ NA COMPANHIA
  // ==========================================
  void _verMembrosDaCompanhia(String nomeCompanhia) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85, // Ocupa 85% da tela
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text(nomeCompanhia, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const Text("Membros alocados", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BUSCA LIDERANÇA
                      const Text("Liderança", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('usuarios').where('companhia', isEqualTo: nomeCompanhia).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("Nenhum líder associado a esta companhia.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              return Card(
                                color: isEscuro ? Colors.black26 : Colors.grey.shade100,
                                elevation: 0,
                                child: ListTile(
                                  leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white, size: 18)),
                                  title: Text(doc['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(doc['funcao']),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 25),

                      // BUSCA JOVENS
                      const Text("Jovens", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('jovens').where('companhia', isEqualTo: nomeCompanhia).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("Nenhum jovem associado a esta companhia.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              return Card(
                                color: isEscuro ? Colors.black26 : Colors.grey.shade100,
                                elevation: 0,
                                child: ListTile(
                                  leading: CircleAvatar(backgroundColor: Colors.green, child: Text(doc['nome'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                  title: Text(doc['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("${doc['idade']} anos"),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Companhias"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarPainelCompanhia(),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.flag),
        label: const Text("Nova Cia", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('companhias').orderBy('criadoEm').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text("Nenhuma companhia criada.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            );
          }

          final companhias = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: companhias.length,
            itemBuilder: (context, index) {
              final cia = companhias[index];
              
              return Dismissible(
                key: ValueKey(cia.id),
                background: Container(
                  alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.delete, color: Colors.white, size: 30),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.edit, color: Colors.white, size: 30),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    _mostrarPainelCompanhia(ciaAtual: cia);
                    return false;
                  } else if (direction == DismissDirection.startToEnd) {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Row(
                            children: [Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28), SizedBox(width: 10), Text("Excluir Cia")],
                          ),
                          content: Text("Tem a certeza que deseja excluir a ${cia['nome']}?", style: const TextStyle(fontSize: 15)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              onPressed: () async {
                                Navigator.of(context).pop(true);
                                await FirebaseFirestore.instance.collection('companhias').doc(cia.id).delete();
                              }, 
                              child: const Text("Excluir", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return false;
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.flag, color: Colors.deepPurple),
                    ),
                    title: Text(cia['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: const Text("Clique para ver membros", style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    onTap: () => _verMembrosDaCompanhia(cia['nome']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}