import 'package:flutter/material.dart';
import './admin/gerenciar_usuarios.dart';
import 'admin/lista_jovens.dart';

class AbaAdmin extends StatefulWidget {
  const AbaAdmin({super.key});

  @override
  State<AbaAdmin> createState() => _AbaAdminState();
}

class _AbaAdminState extends State<AbaAdmin> {
  // Estatísticas do topo
  final int _totalJovens = 150;
  final int _totalConsultores = 24;
  final int _totalCompanhias = 12;

  // ==========================================
  // 1. CRIAR CADASTRO (Focado no Jovem)
  // ==========================================
  void _mostrarPainelCriarCadastro() {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController idadeController = TextEditingController();
    final TextEditingController saudeController = TextEditingController();
    final TextEditingController medicamentoController = TextEditingController(); 
    
    String generoSelecionado = "Masculino";
    bool membroIgreja = true; 
    
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateSheet) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24, 
                left: 24, right: 24, top: 24
              ),
              decoration: BoxDecoration(
                color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white, 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25))
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 20),
                    
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_alt_1, size: 28, color: Colors.blue),
                        SizedBox(width: 10),
                        Text("Adicionar Jovem", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // 1. NOME COMPLETO
                    _construirCampoAdmin("Nome Completo", nomeController, Icons.badge, isEscuro, TextInputType.name),
                    const SizedBox(height: 15),
                    
                    // 2. GÉNERO E IDADE 
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _construirDropdown(
                            "Género", 
                            ["Masculino", "Feminino"], 
                            generoSelecionado, 
                            isEscuro, 
                            (v) => setStateSheet(() => generoSelecionado = v!)
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 2,
                          child: _construirCampoAdmin("Idade", idadeController, Icons.cake, isEscuro, TextInputType.number),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // 3. PROBLEMA DE SAÚDE
                    _construirCampoAdmin("Problema de Saúde (Opcional)", saudeController, Icons.medical_services, isEscuro, TextInputType.text),
                    const SizedBox(height: 15),

                    // 4. MEDICAMENTO EM USO
                    _construirCampoAdmin("Medicamento em uso (Opcional)", medicamentoController, Icons.medication, isEscuro, TextInputType.text),
                    const SizedBox(height: 15),

                    // 5. MEMBRO DA IGREJA (Switch)
                    Container(
                      decoration: BoxDecoration(
                        color: isEscuro ? Colors.black26 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: const Text("É membro da Igreja?", style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(membroIgreja ? "Sim" : "Não", style: TextStyle(color: membroIgreja ? Colors.green : Colors.grey)),
                        activeThumbColor: Colors.blue,
                        secondary: Icon(Icons.church, color: membroIgreja ? Colors.blue : Colors.grey),
                        value: membroIgreja,
                        onChanged: (bool valor) {
                          setStateSheet(() => membroIgreja = valor);
                        },
                      ),
                    ),
                    const SizedBox(height: 35),

                    // BOTÃO DE SALVAR
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          if (nomeController.text.isEmpty || idadeController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha o nome e a idade!"), backgroundColor: Colors.red));
                            return;
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${nomeController.text} cadastrado com sucesso!"), backgroundColor: Colors.green));
                        },
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text("Salvar Jovem", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  // --- WIDGETS DE FORMULÁRIO ---
  Widget _construirCampoAdmin(String label, TextEditingController controller, IconData icone, bool isEscuro, TextInputType tipoTeclado) {
    return TextField(
      controller: controller, 
      keyboardType: tipoTeclado,
      style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label, 
        prefixIcon: Icon(icone, color: Colors.blue), 
        filled: true, 
        fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
      ),
    );
  }

  Widget _construirDropdown(String label, List<String> itens, String valorAtual, bool isEscuro, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: valorAtual, // Usar value em vez de initialValue para atualizar a UI corretamente
      dropdownColor: isEscuro ? const Color(0xFF1E1E1E) : Colors.white, 
      style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label, 
        filled: true, 
        fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), 
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
      ),
      items: itens.map((String valor) => DropdownMenuItem(value: valor, child: Text(valor, style: const TextStyle(fontSize: 14)))).toList(), 
      onChanged: onChanged,
    );
  }

  // ==========================================
  // ROTAS PARA AS NOVAS TELAS
  // ==========================================
  
  void _abrirTelaGerenciarUsuarios() {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const GerenciarUsuarios() 
      )
    );
  }

  // <-- NAVEGAÇÃO CORRIGIDA AQUI! -->
  void _abrirTelaListaJovens() {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const ListaJovensTela()
      )
    );
  }

  void _abrirTelaGerenciarCompanhias() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(
      appBar: AppBar(title: const Text("Gerenciar Companhias")),
      body: const Center(child: Text("Tela de Criação de Cias e Distribuição de Jovens em construção...")),
    )));
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
          const Text("Painel da Liderança", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 5),
          Text("Visão geral do FSY", style: TextStyle(fontSize: 14, color: corTextoSecundario)),
          const SizedBox(height: 20),
          
          Row(
            children: [
              _construirCardEstatistica("Jovens", _totalJovens.toString(), Icons.face, Colors.blue),
              const SizedBox(width: 10),
              _construirCardEstatistica("Equipa", _totalConsultores.toString(), Icons.badge, Colors.teal),
              const SizedBox(width: 10),
              _construirCardEstatistica("Cias", _totalCompanhias.toString(), Icons.flag, Colors.orange),
            ],
          ),
          const SizedBox(height: 35),

          Text("Gestão de Pessoas", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: corTextoSecundario, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          
          _construirBotaoAcao(Icons.person_add, "Adicionar Jovem", "Adicionar novo jovem ao sistema", Colors.blue, isEscuro, _mostrarPainelCriarCadastro),
          _construirBotaoAcao(Icons.manage_accounts, "Gerenciar Usuários", "Editar dados, alterar acessos e redefinir senhas", Colors.orange, isEscuro, _abrirTelaGerenciarUsuarios),
          
          // Este botão agora vai abrir a lista correta
          _construirBotaoAcao(Icons.format_list_bulleted, "Lista de Jovens", "Pesquisar e visualizar todos os cadastrados", Colors.green, isEscuro, _abrirTelaListaJovens),
          
          const SizedBox(height: 25),

          Text("Organização & Logística", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: corTextoSecundario, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          _construirBotaoAcao(Icons.groups, "Gerenciar Companhias", "Criar companhias e distribuir jovens", Colors.deepPurple, isEscuro, _abrirTelaGerenciarCompanhias),
          _construirBotaoAcao(Icons.hotel, "Mapa de Alojamentos", "Verificar distribuição de quartos", Colors.indigo, isEscuro, () {}),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _construirCardEstatistica(String titulo, String valor, IconData icone, Color cor) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isEscuro ? Colors.white12 : Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 28),
            const SizedBox(height: 8),
            Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _construirBotaoAcao(IconData icone, String titulo, String subtitulo, Color cor, bool isEscuro, VoidCallback acao) {
    return Card(
      elevation: 0, color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white, margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: cor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icone, color: cor)),
        title: Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, color: isEscuro ? Colors.white : Colors.black87)),
        subtitle: Text(subtitulo, style: TextStyle(fontSize: 12, color: isEscuro ? Colors.white54 : Colors.black54)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: acao,
      ),
    );
  }
}