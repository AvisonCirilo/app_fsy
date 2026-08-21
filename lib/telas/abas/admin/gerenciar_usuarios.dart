import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; 

class GerenciarUsuarios extends StatefulWidget {
  const GerenciarUsuarios({super.key});

  @override
  State<GerenciarUsuarios> createState() => _GerenciarUsuariosTelaState();
}

class _GerenciarUsuariosTelaState extends State<GerenciarUsuarios> {
  Color _corPorFuncao(String funcao) {
    switch (funcao) {
      case 'Administrador': return Colors.grey.shade600; 
      case 'Diretor': return Colors.black87; // NOVA COR
      case 'Coordenador': return Colors.lightBlue; 
      case 'Coordenador Assistente': return Colors.green; 
      case 'Logística': return Colors.purple; // NOVA COR
      case 'Consultor': return Colors.amber; 
      default: return Colors.grey;
    }
  }

  // ==========================================
  // PAINEL INTELIGENTE (CRIAR E EDITAR NO FIRESTORE)
  // ==========================================
  void _mostrarPainelUsuario({DocumentSnapshot? usuarioAtual}) {
    bool isEdicao = usuarioAtual != null; 
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;
    bool ocultarSenha = true; 

    final nomeCtrl = TextEditingController(text: isEdicao ? usuarioAtual['nome'] : "");
    final usuarioCtrl = TextEditingController(text: isEdicao ? usuarioAtual['usuario'] : "");
    final senhaCtrl = TextEditingController(); 
    final saudeCtrl = TextEditingController(text: isEdicao ? usuarioAtual['saude'] : "");
    final medicamentoCtrl = TextEditingController(text: isEdicao ? usuarioAtual['medicamento'] : "");
    
    final adjuntaCtrl = TextEditingController(text: isEdicao ? (usuarioAtual.data() as Map).containsKey('adjunta') ? usuarioAtual['adjunta'] : "" : "");
    final qtdJovensCtrl = TextEditingController(text: isEdicao ? (usuarioAtual.data() as Map).containsKey('qtdJovens') ? usuarioAtual['qtdJovens'] : "" : "");
    final quartoCtrl = TextEditingController(text: isEdicao ? (usuarioAtual.data() as Map).containsKey('quarto') ? usuarioAtual['quarto'] : "" : "");

    String funcaoSelecionada = isEdicao ? usuarioAtual['funcao'] : "Consultor";

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
              decoration: BoxDecoration(
                color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isEdicao ? Icons.manage_accounts : Icons.person_add, size: 22, color: Colors.grey.shade700),
                        const SizedBox(width: 10),
                        Text(isEdicao ? "Editar Utilizador" : "Novo Utilizador", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 25),

                    _construirCampo("Nome Completo", nomeCtrl, Icons.badge, isEscuro),
                    const SizedBox(height: 15),
                    
                    // MENU ATUALIZADO COM OS NOVOS CARGOS
                    DropdownButtonFormField<String>(
                      value: funcaoSelecionada,
                      dropdownColor: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                      style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                      decoration: InputDecoration(
                        labelText: "Função / Cargo",
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        filled: true, fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5)),
                        prefixIcon: Icon(Icons.work, color: Colors.grey.shade700, size: 20),
                      ),
                      items: ["Administrador", "Diretor", "Coordenador", "Coordenador Assistente", "Logística", "Consultor"]
                          .map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) => setStateSheet(() => funcaoSelecionada = v!),
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(child: _construirCampo("Usuário (Login)", usuarioCtrl, Icons.person, isEscuro, enabled: !isEdicao)),
                        const SizedBox(width: 15),
                        if (!isEdicao) 
                          Expanded(
                            child: _construirCampo(
                              "Senha", senhaCtrl, Icons.lock, isEscuro, obscure: ocultarSenha,
                              suffixIcon: IconButton(
                                icon: Icon(ocultarSenha ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade700, size: 20),
                                onPressed: () => setStateSheet(() => ocultarSenha = !ocultarSenha),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    _construirCampo("Restrição Alimentar/Saúde", saudeCtrl, Icons.health_and_safety, isEscuro),
                    const SizedBox(height: 15),
                    _construirCampo("Uso de Medicamentos", medicamentoCtrl, Icons.medication, isEscuro),
                    
                    if (isEdicao) ...[
                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
                      Align(alignment: Alignment.centerLeft, child: Text("Informações Logísticas (Edição)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
                      const SizedBox(height: 15),
                      _construirCampo("Adjunta(o)", adjuntaCtrl, Icons.supervisor_account, isEscuro),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: _construirCampo("Qtd Jovens", qtdJovensCtrl, Icons.groups, isEscuro, tipo: TextInputType.number)),
                          const SizedBox(width: 15),
                          Expanded(child: _construirCampo("Quarto", quartoCtrl, Icons.hotel, isEscuro)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700, foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        onPressed: () async {
                          if (nomeCtrl.text.isEmpty || usuarioCtrl.text.isEmpty) return;

                          Navigator.pop(context); 
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Salvando no servidor..."), backgroundColor: Colors.grey.shade700));

                          try {
                            if (isEdicao) {
                              await FirebaseFirestore.instance.collection('usuarios').doc(usuarioAtual.id).update({
                                'nome': nomeCtrl.text,
                                'funcao': funcaoSelecionada,
                                'saude': saudeCtrl.text,
                                'medicamento': medicamentoCtrl.text,
                                'adjunta': adjuntaCtrl.text,
                                'qtdJovens': qtdJovensCtrl.text,
                                'quarto': quartoCtrl.text,
                              });
                            } else {
                              if (senhaCtrl.text.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A senha deve ter no mínimo 6 caracteres."), backgroundColor: Colors.redAccent));
                                return;
                              }
                              
                              FirebaseApp appSecundario = await Firebase.initializeApp(name: 'AppSecundario', options: Firebase.app().options);
                              UserCredential cred = await FirebaseAuth.instanceFor(app: appSecundario).createUserWithEmailAndPassword(
                                email: "${usuarioCtrl.text.trim().toLowerCase()}@fsy.com", 
                                password: senhaCtrl.text.trim()
                              );
                              
                              await FirebaseFirestore.instance.collection('usuarios').doc(cred.user!.uid).set({
                                'nome': nomeCtrl.text,
                                'funcao': funcaoSelecionada,
                                'usuario': usuarioCtrl.text.trim().toLowerCase(),
                                'saude': saudeCtrl.text,
                                'medicamento': medicamentoCtrl.text,
                                'companhia': 'A Definir', 
                                'criadoEm': FieldValue.serverTimestamp(),
                              });
                              
                              await appSecundario.delete(); 
                            }
                            if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Utilizador ${isEdicao ? 'atualizado' : 'criado'} com sucesso!"), backgroundColor: Colors.green));
                          } catch (e) {
                            if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.redAccent));
                          }
                        },
                        icon: const Icon(Icons.save, size: 20),
                        label: Text(isEdicao ? "Atualizar Utilizador" : "Criar Utilizador", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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

  Widget _construirCampo(String label, TextEditingController controller, IconData icone, bool isEscuro, {bool obscure = false, TextInputType tipo = TextInputType.text, Widget? suffixIcon, bool enabled = true}) {
    return TextField(
      controller: controller, obscureText: obscure, keyboardType: tipo, enabled: enabled,
      style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: Colors.grey.shade700),
        prefixIcon: Icon(icone, color: Colors.grey.shade700, size: 20), suffixIcon: suffixIcon, 
        filled: true, fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciar Usuários")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarPainelUsuario(), 
        backgroundColor: Colors.grey.shade700, foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add, size: 20),
        label: const Text("Novo", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.amber));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("Nenhum utilizador encontrado.", style: TextStyle(color: Colors.grey.shade600)));

          final usuarios = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              
              return Dismissible(
                key: ValueKey(usuario.id), 
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
                    _mostrarPainelUsuario(usuarioAtual: usuario);
                    return false; 
                  } else if (direction == DismissDirection.startToEnd) { 
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28), SizedBox(width: 10), Text("Excluir Utilizador")]),
                          content: Text("Tem a certeza que deseja excluir ${usuario['nome']} do sistema?", style: const TextStyle(fontSize: 15)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              onPressed: () async {
                                Navigator.of(context).pop(true);
                                await FirebaseFirestore.instance.collection('usuarios').doc(usuario.id).delete();
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
                    leading: CircleAvatar(
                      backgroundColor: _corPorFuncao(usuario['funcao']),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    title: Text(usuario['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${usuario['funcao']} | User: ${usuario['usuario']}"),
                    onTap: () => _mostrarPainelUsuario(usuarioAtual: usuario),
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