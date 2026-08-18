import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';

// IMPORTANTE: Altere este caminho para onde estiver o ficheiro da sua tela de Login!
// Se estiver na pasta telas, normalmente é assim:
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
      _nomeController.text = prefs.getString('perfil_nome') ?? "Seu Nome Completo";
      _funcaoController.text = prefs.getString('perfil_funcao') ?? "Consultor(a)";
      _companhiaController.text = prefs.getString('perfil_companhia') ?? "Companhia 00";
      
      _responsavelController.text = prefs.getString('perfil_responsavel') ?? "12";
      _adjuntaController.text = prefs.getString('perfil_adjunta') ?? "Nome da Adjunta";
      
      _alojamentoController.text = prefs.getString('perfil_alojamento') ?? "Bloco X - Quarto 00";
      _restricoesController.text = prefs.getString('perfil_restricoes') ?? "Nenhuma";
      
      _modoEscuro = prefs.getBool('config_modo_escuro') ?? false;
      
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

  // --- NOVA FUNÇÃO: FAZER LOGOUT ---
  void _sairDaConta() {
    // Aqui usamos o comando que destrói o histórico de telas e joga para o Login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const TelaLogin()), // Garanta que a sua classe de login tem este nome!
      (Route<dynamic> route) => false, // Isto apaga todas as rotas anteriores
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
          ),

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
                  activeColor: Colors.grey,
                  onChanged: (bool valor) {
                    setState(() => _modoEscuro = valor);
                    _salvarPerfil(); 
                    temaGlobalNotifier.value = valor ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 35), // Espaçamento extra

          // ==========================================
          // 5. BOTÃO DE SAIR DA CONTA (LOGOUT)
          // ==========================================
          SizedBox(
            width: double.infinity, // Ocupa a largura toda
            child: ElevatedButton.icon(
              onPressed: _sairDaConta, // Chama a função de Logout
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1), // Fundo vermelho translúcido chique
                foregroundColor: Colors.redAccent, // Texto vermelho
                elevation: 0, // Sem sombra
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.redAccent, width: 1.5), // Bordinha vermelha
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Sair da Conta", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30), // Espaçamento para o botão não colar no fundo do ecrã
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