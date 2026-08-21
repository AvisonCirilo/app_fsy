import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

// Importação das telas de gestão
import './admin/gerenciar_usuarios.dart';
import 'admin/lista_jovens.dart';
import 'admin/gerenciar_companhias.dart';
import 'admin/mapa_alojamentos.dart';

class AbaAdmin extends StatefulWidget {
  const AbaAdmin({super.key});

  @override
  State<AbaAdmin> createState() => _AbaAdminState();
}

class _AbaAdminState extends State<AbaAdmin> {

  // ==========================================
  // 1. ROTAS DE NAVEGAÇÃO
  // ==========================================
  void _abrirTelaGerenciarUsuarios() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const GerenciarUsuarios()));
  }

  void _abrirTelaListaJovens() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ListaJovensTela()));
  }

  void _abrirTelaGerenciarCompanhias() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const GerenciarCompanhias()));
  }

  void _abrirMapaAlojamentos() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MapaAlojamentos()));
  }

  // ==========================================
  // 2. CONSTRUÇÃO DA TELA PRINCIPAL
  // ==========================================
  @override
  Widget build(BuildContext context) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;
    Color corTextoSecundario = isEscuro ? Colors.white70 : Colors.black54;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Cabeçalho ---
          const Text("Painel da Liderança", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 5),
          Text("Visão geral em Tempo Real", style: TextStyle(fontSize: 14, color: corTextoSecundario)),
          const SizedBox(height: 20),
          
          // --- Cards de Estatística (Firestore) ---
          Row(
            children: [
              _construirCardRealTime("Jovens", Icons.face, Colors.blue, 'jovens'),
              const SizedBox(width: 10),
              _construirCardRealTime("Equipe", Icons.badge, Colors.teal, 'usuarios'),
              const SizedBox(width: 10),
              _construirCardRealTime("Companhias", Icons.flag, Colors.orange, 'companhias'),
            ],
          ),
          const SizedBox(height: 35),

          // --- Gestão de Pessoas ---
          Text("Gestão de Pessoas", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: corTextoSecundario, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          
          _construirBotaoAcao(Icons.manage_accounts, "Gerenciar Usuários", "Editar dados, alterar acessos e redefinir senhas da Liderança", Colors.orange, isEscuro, _abrirTelaGerenciarUsuarios),
          _construirBotaoAcao(Icons.format_list_bulleted, "Lista de Jovens", "Pesquisar, adicionar e gerenciar todos os jovens cadastrados", Colors.green, isEscuro, _abrirTelaListaJovens),
          
          const SizedBox(height: 25),

          // --- Organização e Logística ---
          Text("Organização & Logística", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: corTextoSecundario, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          
          _construirBotaoAcao(Icons.groups, "Gerenciar Companhias", "Criar companhias e distribuir jovens", Colors.deepPurple, isEscuro, _abrirTelaGerenciarCompanhias),
          // LIGAÇÃO CORRIGIDA AQUI: O botão agora chama o _abrirMapaAlojamentos em vez de () {}
          _construirBotaoAcao(Icons.hotel, "Mapa de Alojamentos", "Verificar distribuição de quartos", Colors.indigo, isEscuro, _abrirMapaAlojamentos),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==========================================
  // 3. WIDGETS AUXILIARES (REUTILIZÁVEIS)
  // ==========================================
  
  // Widget que lê do Firestore e atualiza o número em tempo real
  Widget _construirCardRealTime(String titulo, IconData icone, Color cor, String colecao) {
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(colecao).snapshots(),
          builder: (context, snapshot) {
            String valor = "..."; 
            
            if (snapshot.hasData) {
              valor = snapshot.data!.docs.length.toString();
            }

            return Column(
              children: [
                Icon(icone, color: cor, size: 28),
                const SizedBox(height: 8),
                Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            );
          }
        ),
      ),
    );
  }

  // Widget que cria o design padrão dos botões de menu
  Widget _construirBotaoAcao(IconData icone, String titulo, String subtitulo, Color cor, bool isEscuro, VoidCallback acao) {
    return Card(
      elevation: 0, 
      color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white, 
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10), 
          decoration: BoxDecoration(color: cor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), 
          child: Icon(icone, color: cor)
        ),
        title: Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, color: isEscuro ? Colors.white : Colors.black87)),
        subtitle: Text(subtitulo, style: TextStyle(fontSize: 12, color: isEscuro ? Colors.white54 : Colors.black54)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: acao,
      ),
    );
  }
}