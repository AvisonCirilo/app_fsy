import 'package:flutter/material.dart';

class AbaAdmin extends StatelessWidget {
  const AbaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;
    Color corTextoSecundario = isEscuro ? Colors.white70 : Colors.black54;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Painel da Liderança",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 5),
          Text(
            "Bem-vindo ao Modo Deus. O que deseja gerir hoje?",
            style: TextStyle(fontSize: 14, color: corTextoSecundario),
          ),
          const SizedBox(height: 30),

          // Botões de Ação Rápida
          _construirBotaoAdmin(Icons.person_add, "Criar Conta de Usuário", "Adicionar novo jovem ou consultor", Colors.blue, context),
          _construirBotaoAdmin(Icons.swap_horiz, "Gerir Companhias", "Mover jovens entre grupos", Colors.orange, context),
          
          // --- O NOVO BOTÃO DE SENHA ---
          _construirBotaoAdmin(Icons.lock_reset, "Redefinir Senha", "Alterar a senha de um usuário", Colors.green, context),
          
          _construirBotaoAdmin(Icons.health_and_safety, "Ficha Médica Geral", "Acesso às restrições de saúde", Colors.redAccent, context),
        ],
      ),
    );
  }

  // Molde para os botões do painel Admin
  Widget _construirBotaoAdmin(IconData icone, String titulo, String subtitulo, Color cor, BuildContext context) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: cor.withValues(alpha: 0.2),
          child: Icon(icone, color: cor),
        ),
        title: Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, color: isEscuro ? Colors.white : Colors.black87)),
        subtitle: Text(subtitulo, style: TextStyle(color: isEscuro ? Colors.white54 : Colors.black54)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // No futuro, ao clicar aqui, faremos a tela específica abrir por cima!
          // Ex: Navigator.push(context, MaterialPageRoute(builder: (context) => TelaMudarSenha()));
        },
      ),
    );
  }
}