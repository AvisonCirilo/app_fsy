import 'package:flutter/material.dart';

class GerenciarUsuarios extends StatefulWidget {
  const GerenciarUsuarios({super.key});

  @override
  State<GerenciarUsuarios> createState() => _GerenciarUsuariosTelaState();
}

class _GerenciarUsuariosTelaState extends State<GerenciarUsuarios> {
  // Simulação de lista de usuários (No futuro, virá do Firebase)
  final List<Map<String, String>> _usuarios = [
    {"nome": "Maria Consultora", "funcao": "Consultor"},
    {"nome": "Carlos Admin", "funcao": "Admin"},
    {"nome": "João Jovem", "funcao": "Jovem"},
  ];

  @override
  Widget build(BuildContext context) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciar Usuários")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: usuario['funcao'] == 'Admin' ? Colors.redAccent : Colors.blue,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text(usuario['nome']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(usuario['funcao']!),
              trailing: const Icon(Icons.edit, color: Colors.grey),
              onTap: () => _editarUsuario(usuario),
            ),
          );
        },
      ),
    );
  }

  void _editarUsuario(Map<String, String> usuario) {
    // Aqui abrimos o formulário de edição
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Editando: ${usuario['nome']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Aqui iriam os campos de texto para nome, email, funcao, etc.
            const ListTile(leading: Icon(Icons.vpn_key), title: Text("Redefinir Senha")),
            const ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text("Remover Usuário", style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}