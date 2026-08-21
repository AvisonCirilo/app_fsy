import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../main.dart'; 
import '../login_tela.dart';

class AbaPerfil extends StatefulWidget {
  const AbaPerfil({super.key});

  @override
  State<AbaPerfil> createState() => _AbaPerfilState();
}

class _AbaPerfilState extends State<AbaPerfil> {
  bool _editando = false;
  bool _modoEscuro = false;
  String? _caminhoFotoPerfil;
  String _funcaoLogada = ""; 

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _funcaoController = TextEditingController();
  final TextEditingController _companhiaController = TextEditingController();
  
  final TextEditingController _responsavelController = TextEditingController();
  final TextEditingController _adjuntaController = TextEditingController();
  
  final TextEditingController _alojamentoController = TextEditingController();
  final TextEditingController _restricoesController = TextEditingController();

  final ImagePicker _selecionadorDeImagem = ImagePicker();

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _funcaoLogada = prefs.getString('perfil_funcao') ?? "Consultor";

      _nomeController.text = prefs.getString('perfil_nome') ?? "Seu Nome Completo";
      _funcaoController.text = _funcaoLogada; 
      _companhiaController.text = prefs.getString('perfil_companhia') ?? "Companhia 00";
      
      _responsavelController.text = prefs.getString('perfil_responsavel') ?? "12";
      _adjuntaController.text = prefs.getString('perfil_adjunta') ?? "Nome da Adjunta";
      
      _alojamentoController.text = prefs.getString('perfil_alojamento') ?? "Bloco X - Quarto 00";
      _restricoesController.text = prefs.getString('perfil_restricoes') ?? "Nenhuma";
      
      _modoEscuro = prefs.getBool('config_modo_escuro') ?? false;
      
      _caminhoFotoPerfil = prefs.getString('perfil_foto');
    });
  }

  // ==========================================
  // SALVAR PERFIL (AGORA SINCRONIZA COM O FIRESTORE)
  // ==========================================
  Future<void> _salvarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('perfil_nome', _nomeController.text);
    await prefs.setString('perfil_funcao', _funcaoController.text);
    await prefs.setString('perfil_companhia', _companhiaController.text);
    
    await prefs.setString('perfil_responsavel', _responsavelController.text);
    await prefs.setString('perfil_adjunta', _adjuntaController.text);
    
    await prefs.setString('perfil_alojamento', _alojamentoController.text);
    await prefs.setString('perfil_restricoes', _restricoesController.text);
    
    await prefs.setBool('config_modo_escuro', _modoEscuro);

    // Salva as alterações no Banco de Dados Real para que o Admin veja!
    User? usuarioLogado = FirebaseAuth.instance.currentUser;
    if (usuarioLogado != null && _editando) {
      try {
        await FirebaseFirestore.instance.collection('usuarios').doc(usuarioLogado.uid).update({
          'nome': _nomeController.text,
          'saude': _restricoesController.text,
          'quarto': _alojamentoController.text,
          // Se for Admin, ele também pode ter alterado a companhia dele mesmo ou adjunta
          'companhia': _companhiaController.text,
          'adjunta': _adjuntaController.text,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil atualizado no servidor!"), backgroundColor: Colors.green));
        }
      } catch (e) {
         debugPrint("Erro ao atualizar Firestore: $e");
      }
    }
  }

  // ==========================================
  // LÓGICA DE TROCA DE SENHA COM FIREBASE
  // ==========================================
  void _mostrarDialogoTrocarSenha() {
    final TextEditingController senhaAtualCtrl = TextEditingController();
    final TextEditingController novaSenhaCtrl = TextEditingController();
    final TextEditingController confirmarSenhaCtrl = TextEditingController();
    bool carregando = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset, color: Colors.blue),
                  SizedBox(width: 10),
                  Text("Alterar Senha"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: senhaAtualCtrl,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Senha Atual", prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: novaSenhaCtrl,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Nova Senha", prefixIcon: const Icon(Icons.key), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmarSenhaCtrl,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Confirmar Nova Senha", prefixIcon: const Icon(Icons.key), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ],
              ),
              actions: [
                if (!carregando)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: carregando ? null : () async {
                    if (novaSenhaCtrl.text != confirmarSenhaCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("As novas senhas não coincidem!"), backgroundColor: Colors.redAccent));
                      return;
                    }
                    if (novaSenhaCtrl.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A nova senha deve ter no mínimo 6 caracteres."), backgroundColor: Colors.redAccent));
                      return;
                    }

                    setStateDialog(() => carregando = true);

                    try {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null && user.email != null) {
                        // 1. Reautentica o usuário para provar que é ele mesmo
                        AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: senhaAtualCtrl.text);
                        await user.reauthenticateWithCredential(credential);
                        
                        // 2. Atualiza a senha se a atual estiver correta
                        await user.updatePassword(novaSenhaCtrl.text);
                        
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Senha alterada com sucesso!"), backgroundColor: Colors.green));
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      String erro = "Erro ao alterar senha.";
                      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                        erro = "A senha atual está incorreta.";
                      }
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro), backgroundColor: Colors.redAccent));
                      }
                    } finally {
                      setStateDialog(() => carregando = false);
                    }
                  },
                  child: carregando 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Salvar Senha", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _escolherFotoDaGaleria() async {
    try {
      final XFile? fotoEscolhida = await _selecionadorDeImagem.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, 
      );

      if (fotoEscolhida != null) {
        setState(() {
          _caminhoFotoPerfil = fotoEscolhida.path;
        });
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('perfil_foto', fotoEscolhida.path);
      }
    } catch (e) {
      debugPrint("Erro ao abrir galeria: $e");
    }
  }

  Future<void> _removerFoto() async {
    setState(() {
      _caminhoFotoPerfil = null;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('perfil_foto');
  }

  void _mostrarOpcoesDaFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Foto de Perfil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Carregar da Galeria'),
                onTap: () {
                  Navigator.of(context).pop(); 
                  _escolherFotoDaGaleria(); 
                },
              ),
              if (_caminhoFotoPerfil != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover Foto', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop(); 
                    _removerFoto(); 
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _sairDaConta() async {
    await FirebaseAuth.instance.signOut(); // Desloga do Firebase também
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const TelaLogin()), 
      (Route<dynamic> route) => false, 
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;
    Color corTextoPrincipal = isEscuro ? Colors.white : Colors.black87;
    Color corTextoSecundario = isEscuro ? Colors.white70 : Colors.black54;

    bool isAdmin = _funcaoLogada.toLowerCase().contains('admin'); 

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          if (isAdmin)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  _editando ? Icons.check_circle : Icons.edit,
                  color: _editando ? Colors.green : Colors.grey,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    if (_editando) _salvarPerfil();
                    _editando = !_editando; 
                  });
                },
              ),
            )
          else
            const SizedBox(height: 48), 

          // ==========================================
          // 1. CABEÇALHO DO PERFIL (FOTO E NOME)
          // ==========================================
          Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.blueGrey,
                    backgroundImage: _caminhoFotoPerfil != null ? FileImage(File(_caminhoFotoPerfil!)) : null,
                    child: _caminhoFotoPerfil == null ? const Icon(Icons.person, size: 65, color: Colors.white) : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        onPressed: _mostrarOpcoesDaFoto,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              _editando 
                  ? _construirCampoEdicao("Nome", _nomeController, corTextoPrincipal)
                  : Text(_nomeController.text, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: corTextoPrincipal)),
              
              _editando 
                  ? _construirCampoEdicao("Função", _funcaoController, corTextoSecundario)
                  : Text(_funcaoController.text, style: TextStyle(fontSize: 14, color: corTextoSecundario, fontWeight: FontWeight.w500)),
              
              const SizedBox(height: 10),
              
              _editando 
                  ? _construirCampoEdicao("Companhia", _companhiaController, Colors.green)
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text(_companhiaController.text, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
            ],
          ),
          const SizedBox(height: 30),

          // ==========================================
          // 2. PAINEL DE EQUIPA E PROGRESSO
          // ==========================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirInfoDinamica(legenda: "Jovens", controlador: _responsavelController, corTextoPrincipal: Colors.blue, corTextoSecundario: corTextoSecundario, dica: "Ex: 12"),
              _construirInfoDinamica(legenda: "Adjunta(o)", controlador: _adjuntaController, corTextoPrincipal: Colors.blue, corTextoSecundario: corTextoSecundario, dica: "Nome"),
              Expanded(
                child: Column(
                  children: [
                    const Text("Dia 1", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 4),
                    Text("Progresso", style: TextStyle(fontSize: 12, color: corTextoSecundario)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // ==========================================
          // 3. INFORMAÇÕES DE LOGÍSTICA
          // ==========================================
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Ficha do Evento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corTextoSecundario)),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.hotel, color: Colors.blue),
                  title: const Text("Alojamento", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: _editando 
                      ? _construirCampoEdicao("Ex: Bloco B - Quarto 204", _alojamentoController, corTextoPrincipal)
                      : Text(_alojamentoController.text, style: TextStyle(fontSize: 16, color: corTextoPrincipal)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.orange),
                  title: const Text("Restrições Alimentares", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: _editando 
                      ? _construirCampoEdicao("Ex: Intolerância à Lactose", _restricoesController, corTextoPrincipal)
                      : Text(_restricoesController.text, style: TextStyle(fontSize: 16, color: corTextoPrincipal)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // ==========================================
          // 4. CONFIGURAÇÕES DO APLICATIVO
          // ==========================================
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Preferências", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corTextoSecundario)),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode, color: Colors.grey),
                  title: const Text("Modo Escuro"),
                  value: _modoEscuro,
                  activeThumbColor: Colors.grey,
                  onChanged: (bool valor) {
                    setState(() => _modoEscuro = valor);
                    _salvarPerfil(); 
                    temaGlobalNotifier.value = valor ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
                const Divider(height: 1),
                // O NOVO BOTÃO DE ALTERAR SENHA AQUI!
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Colors.grey),
                  title: const Text("Alterar Senha"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: _mostrarDialogoTrocarSenha,
                ),
              ],
            ),
          ),
          const SizedBox(height: 35), 

          // ==========================================
          // 5. BOTÃO DE SAIR DA CONTA (LOGOUT)
          // ==========================================
          SizedBox(
            width: double.infinity, 
            child: ElevatedButton.icon(
              onPressed: _sairDaConta, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1), 
                foregroundColor: Colors.redAccent, 
                elevation: 0, 
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.redAccent, width: 1.5), 
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Sair da Conta", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30), 
        ],
      ),
    );
  }

  Widget _construirInfoDinamica({required String legenda, required TextEditingController controlador, required Color corTextoPrincipal, required Color corTextoSecundario, required String dica}) {
    return Expanded(
      child: Column(
        children: [
          _editando 
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextField(
                  controller: controlador, textAlign: TextAlign.center,
                  style: TextStyle(color: corTextoPrincipal, fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(hintText: dica, isDense: true, contentPadding: const EdgeInsets.all(4), border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue))),
                ),
              )
            : Text(controlador.text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corTextoPrincipal), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(legenda, style: TextStyle(fontSize: 12, color: corTextoSecundario)),
        ],
      ),
    );
  }

  Widget _construirCampoEdicao(String dica, TextEditingController controlador, Color corTexto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: controlador, textAlign: TextAlign.center, style: TextStyle(color: corTexto),
        decoration: InputDecoration(hintText: dica, isDense: true, contentPadding: const EdgeInsets.all(8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blue))),
      ),
    );
  }
}