import 'package:flutter/material.dart';

class GerenciarUsuarios extends StatefulWidget {
  const GerenciarUsuarios({super.key});

  @override
  State<GerenciarUsuarios> createState() => _GerenciarUsuariosTelaState();
}

class _GerenciarUsuariosTelaState extends State<GerenciarUsuarios> {
  // Simulação de lista de usuários
  final List<Map<String, dynamic>> _usuarios = [
    {"nome": "Carlos Silva", "funcao": "Administrador", "usuario": "carlos.admin", "quarto": "Staff 1", "qtdJovens": "0", "adjunta": "", "saude": "Nenhuma", "medicamento": ""},
    {"nome": "Roberto Coord", "funcao": "Coordenador", "usuario": "roberto.c", "quarto": "Staff 2", "qtdJovens": "0", "adjunta": "", "saude": "Lactose", "medicamento": ""},
    {"nome": "Ana Assistente", "funcao": "Coordenador Assistente", "usuario": "ana.a", "quarto": "A-100", "qtdJovens": "24", "adjunta": "Roberto Coord", "saude": "Amendoim", "medicamento": "Antialérgico"},
    {"nome": "Maria Consultora", "funcao": "Consultor", "usuario": "maria.c", "quarto": "A-101", "qtdJovens": "12", "adjunta": "Ana Assistente", "saude": "Nenhuma", "medicamento": ""},
  ];

  Color _corPorFuncao(String funcao) {
    switch (funcao) {
      case 'Administrador': return Colors.grey.shade600; 
      case 'Coordenador': return Colors.lightBlue; 
      case 'Coordenador Assistente': return Colors.green; 
      case 'Consultor': return Colors.amber; 
      default: return Colors.grey;
    }
  }

  // ==========================================
  // PAINEL INTELIGENTE (CRIAR E EDITAR)
  // ==========================================
  void _mostrarPainelUsuario({Map<String, dynamic>? usuarioAtual}) {
    bool isEdicao = usuarioAtual != null; 
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    bool ocultarSenha = true; 

    final nomeCtrl = TextEditingController(text: isEdicao ? usuarioAtual['nome'] : "");
    final usuarioCtrl = TextEditingController(text: isEdicao ? usuarioAtual['usuario'] : "");
    final senhaCtrl = TextEditingController(); 
    final saudeCtrl = TextEditingController(text: isEdicao ? usuarioAtual['saude'] : "");
    final medicamentoCtrl = TextEditingController(text: isEdicao ? usuarioAtual['medicamento'] : "");
    
    final adjuntaCtrl = TextEditingController(text: isEdicao ? usuarioAtual['adjunta'] : "");
    final qtdJovensCtrl = TextEditingController(text: isEdicao ? usuarioAtual['qtdJovens'] : "");
    final quartoCtrl = TextEditingController(text: isEdicao ? usuarioAtual['quarto'] : "");

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
                    
                    DropdownButtonFormField<String>(
                      value: funcaoSelecionada,
                      dropdownColor: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                      style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                      decoration: InputDecoration(
                        labelText: "Função / Cargo",
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        filled: true,
                        fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5)),
                        prefixIcon: Icon(Icons.work, color: Colors.grey.shade700, size: 20),
                      ),
                      items: ["Administrador", "Coordenador", "Coordenador Assistente", "Consultor"]
                          .map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) => setStateSheet(() => funcaoSelecionada = v!),
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(child: _construirCampo("Usuário (Login)", usuarioCtrl, Icons.person, isEscuro)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _construirCampo(
                            isEdicao ? "Nova Senha" : "Senha", 
                            senhaCtrl, 
                            Icons.lock, 
                            isEscuro, 
                            obscure: ocultarSenha,
                            suffixIcon: IconButton(
                              icon: Icon(
                                ocultarSenha ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey.shade700,
                                size: 20,
                              ),
                              onPressed: () {
                                setStateSheet(() {
                                  ocultarSenha = !ocultarSenha;
                                });
                              },
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Informações Logísticas (Edição)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                      ),
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
                          backgroundColor: Colors.grey.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        onPressed: () {
                          setState(() {
                            if (isEdicao) {
                              usuarioAtual['nome'] = nomeCtrl.text;
                              usuarioAtual['funcao'] = funcaoSelecionada;
                              usuarioAtual['usuario'] = usuarioCtrl.text;
                              usuarioAtual['saude'] = saudeCtrl.text;
                              usuarioAtual['medicamento'] = medicamentoCtrl.text;
                              usuarioAtual['adjunta'] = adjuntaCtrl.text;
                              usuarioAtual['qtdJovens'] = qtdJovensCtrl.text;
                              usuarioAtual['quarto'] = quartoCtrl.text;
                            } else {
                              _usuarios.add({
                                "nome": nomeCtrl.text,
                                "funcao": funcaoSelecionada,
                                "usuario": usuarioCtrl.text,
                                "saude": saudeCtrl.text,
                                "medicamento": medicamentoCtrl.text,
                                "adjunta": "",
                                "qtdJovens": "",
                                "quarto": "",
                              });
                            }
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Utilizador ${isEdicao ? 'atualizado' : 'criado'} com sucesso!"), backgroundColor: Colors.grey.shade700),
                          );
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

  Widget _construirCampo(String label, TextEditingController controller, IconData icone, bool isEscuro, {bool obscure = false, TextInputType tipo = TextInputType.text, Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: tipo,
      style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        prefixIcon: Icon(icone, color: Colors.grey.shade700, size: 20),
        suffixIcon: suffixIcon, 
        filled: true,
        fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Usuários"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarPainelUsuario(), 
        backgroundColor: Colors.grey.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add, size: 20),
        label: const Text("Novo", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          
          return Dismissible(
            key: ValueKey(usuario['usuario']), 
            
            // AGORA: FUNDO 1 (Deslizar Direita -> Excluir)
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.delete, color: Colors.white, size: 30),
            ),

            // AGORA: FUNDO 2 (Deslizar Esquerda -> Editar)
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.edit, color: Colors.white, size: 30),
            ),
            
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) { // Deslizou para ESQUERDA
                _mostrarPainelUsuario(usuarioAtual: usuario);
                return false; // Abre edição e impede que suma
              } else if (direction == DismissDirection.startToEnd) { // Deslizou para DIREITA
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                          SizedBox(width: 10),
                          Text("Excluir Utilizador"),
                        ],
                      ),
                      content: Text("Tem a certeza que deseja excluir ${usuario['nome']} do sistema?\n\nEsta ação não poderá ser desfeita.", style: const TextStyle(fontSize: 15)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false), 
                          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                        ),
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
              if (direction == DismissDirection.startToEnd) { // Remove se a ação for deslizar para a direita
                setState(() {
                  _usuarios.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${usuario['nome']} foi removido."), backgroundColor: Colors.redAccent),
                );
              }
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
                title: Text(usuario['nome']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${usuario['funcao']!} | User: ${usuario['usuario']!}"),
                onTap: () => _mostrarPainelUsuario(usuarioAtual: usuario),
              ),
            ),
          );
        },
      ),
    );
  }
}