import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';

// IMPORTANTE: Altere este caminho para onde estiver o ficheiro da sua tela de Login!
import '../login_tela.dart'; 

class AbaPerfil extends StatefulWidget {
  const AbaPerfil({super.key});

  @override
  State<AbaPerfil> createState() => _AbaPerfilState();
}

class _AbaPerfilState extends State<AbaPerfil> {
  bool _editando = false;
  bool _modoEscuro = false;
  
  // NOVO: Variável que define as permissões da tela!
  bool _isAdmin = false; 
  
  String? _caminhoFotoPerfil; 
  String _generoSelecionado = 'Masculino'; 

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
      String funcaoSalva = prefs.getString('perfil_funcao') ?? "Consultor(a)";
      
      // A MÁGICA DA PERMISSÃO: Verifica se a pessoa logada é um Admin
      _isAdmin = funcaoSalva.toLowerCase().contains('admin');

      _nomeController.text = prefs.getString('perfil_nome') ?? "Seu Nome Completo";
      _funcaoController.text = funcaoSalva;
      _companhiaController.text = prefs.getString('perfil_companhia') ?? "Companhia 00";
      
      _responsavelController.text = prefs.getString('perfil_responsavel') ?? "12";
      _adjuntaController.text = prefs.getString('perfil_adjunta') ?? "Nome da Adjunta";
      
      _alojamentoController.text = prefs.getString('perfil_alojamento') ?? "Bloco X - Quarto 00";
      _restricoesController.text = prefs.getString('perfil_restricoes') ?? "Nenhuma";
      
      _modoEscuro = prefs.getBool('config_modo_escuro') ?? false;
      _generoSelecionado = prefs.getString('perfil_genero') ?? "Masculino"; 
      
      _caminhoFotoPerfil = prefs.getString('perfil_foto');
    });
  }

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
    await prefs.setString('perfil_genero', _generoSelecionado); 
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Foto de Perfil",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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

  void _mostrarPainelTrocarSenha(BuildContext context, bool isEscuro) {
    final TextEditingController senhaAtualCtrl = TextEditingController();
    final TextEditingController novaSenhaCtrl = TextEditingController();
    final TextEditingController confirmarSenhaCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      backgroundColor: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              
              const Icon(Icons.lock_reset, size: 50, color: Colors.blue),
              const SizedBox(height: 10),
              const Text("Trocar Senha", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _construirCampoSenha("Senha Atual", senhaAtualCtrl, isEscuro),
              const SizedBox(height: 10),
              _construirCampoSenha("Nova Senha", novaSenhaCtrl, isEscuro),
              const SizedBox(height: 10),
              _construirCampoSenha("Confirmar Nova Senha", confirmarSenhaCtrl, isEscuro),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (novaSenhaCtrl.text.isEmpty || confirmarSenhaCtrl.text.isEmpty) return; 
                    if (novaSenhaCtrl.text == confirmarSenhaCtrl.text) {
                      Navigator.pop(context); 
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Senha alterada com sucesso!"), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("As novas senhas não coincidem!"), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text("Atualizar Senha", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _construirCampoSenha(String titulo, TextEditingController controller, bool isEscuro) {
    return TextField(
      controller: controller,
      obscureText: true, 
      style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: titulo,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
      ),
    );
  }

  void _sairDaConta() {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          
          // ==========================================
          // BOTÃO DE EDITAR (SÓ APARECE SE FOR ADMIN)
          // ==========================================
          if (_isAdmin)
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
                    if (_editando) {
                      _salvarPerfil();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Perfil atualizado!"), backgroundColor: Colors.green),
                      );
                    }
                    _editando = !_editando; 
                  });
                },
              ),
            )
          else
            const SizedBox(height: 48), // Espaço vazio para não estragar o alinhamento da foto quando o botão não existe!

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
                    backgroundImage: _caminhoFotoPerfil != null
                        ? FileImage(File(_caminhoFotoPerfil!))
                        : null,
                    child: _caminhoFotoPerfil == null
                        ? const Icon(Icons.person, size: 65, color: Colors.white)
                        : null,
                  ),
                  // A CÂMERA FICA SEMPRE ATIVA PARA TODOS!
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
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _companhiaController.text,
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
              
              const SizedBox(height: 10),

              if (_editando)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: _generoSelecionado,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blue)),
                    ),
                    dropdownColor: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                    items: ['Masculino', 'Feminino'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(color: corTextoPrincipal, fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (novoValor) {
                      setState(() => _generoSelecionado = novoValor!);
                    },
                  ),
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
              _construirInfoDinamica(
                legenda: "Jovens",
                controlador: _responsavelController,
                corTextoPrincipal: Colors.blue,
                corTextoSecundario: corTextoSecundario,
                dica: "Ex: 12",
              ),
              
              _construirInfoDinamica(
                legenda: "Adjunta(o)",
                controlador: _adjuntaController,
                corTextoPrincipal: Colors.blue,
                corTextoSecundario: corTextoSecundario,
                dica: "Nome",
              ),

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
          // 4. SEGURANÇA E CONFIGURAÇÕES
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
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Colors.blue),
                  title: const Text("Trocar Senha", style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () => _mostrarPainelTrocarSenha(context, isEscuro),
                ),
                const Divider(height: 1),
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
  
  Widget _construirInfoDinamica({
    required String legenda, 
    required TextEditingController controlador, 
    required Color corTextoPrincipal, 
    required Color corTextoSecundario,
    required String dica,
  }) {
    return Expanded(
      child: Column(
        children: [
          _editando 
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextField(
                  controller: controlador,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: corTextoPrincipal, fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: dica,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(4),
                    border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                  ),
                ),
              )
            : Text(
                controlador.text, 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corTextoPrincipal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
        controller: controlador,
        textAlign: TextAlign.center,
        style: TextStyle(color: corTexto),
        decoration: InputDecoration(
          hintText: dica,
          isDense: true,
          contentPadding: const EdgeInsets.all(8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}