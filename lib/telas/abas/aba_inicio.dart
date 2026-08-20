import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbaInicio extends StatefulWidget {
  final VoidCallback? irParaAgenda;
  const AbaInicio({super.key, this.irParaAgenda});

  @override
  State<AbaInicio> createState() => _AbaInicioState();
}

class _AbaInicioState extends State<AbaInicio> {
  final TextEditingController _notasController = TextEditingController();
  Timer? _relogio;
  DateTime _horaAtual = DateTime.now();
  int _diaAtual = 1;
  
  String _generoConsultor = ""; 
  String _nomeConsultorLogado = ""; 
  String _funcaoLogada = "";

  final List<Map<String, dynamic>> _todosEventos = [
    {"id": "0_1", "dia": 0, "horarioInicial": "19:00", "horarioFinal": "20:00", "titulo": "Mensagem do casal diretor", "cor": Colors.deepPurple, "concluido": false},
    {"id": "0_2", "dia": 0, "horarioInicial": "20:15", "horarioFinal": "21:15", "titulo": "Reuniões CA e Consultores", "cor": Colors.deepPurple, "concluido": false},
    {"id": "0_3", "dia": 0, "horarioInicial": "21:20", "horarioFinal": "21:50", "titulo": "Reunião de Coordenadores", "cor": Colors.deepPurple, "concluido": false},
    {"id": "1_1", "dia": 1, "horarioInicial": "07:30", "horarioFinal": "08:20", "titulo": "Desjejum da Equipe", "cor": Colors.orange, "concluido": false},
    {"id": "1_2", "dia": 1, "horarioInicial": "08:30", "horarioFinal": "09:15", "titulo": "Reunião administrativa", "cor": Colors.deepPurple, "concluido": false},
    {"id": "1_3", "dia": 1, "horarioInicial": "09:15", "horarioFinal": "10:45", "titulo": "Distribuição materiais/Ensaio", "cor": Colors.blueGrey, "concluido": false},
    {"id": "1_4", "dia": 1, "horarioInicial": "11:00", "horarioFinal": "13:00", "titulo": "Check-in / Almoço", "cor": Colors.orange, "concluido": false},
    {"id": "1_5", "dia": 1, "horarioInicial": "13:15", "horarioFinal": "14:00", "titulo": "Conheça seu consultor", "cor": Colors.green, "concluido": false},
    {"id": "1_6", "dia": 1, "horarioInicial": "14:15", "horarioFinal": "15:25", "titulo": "Conheça cia + Elaborar Metas", "cor": Colors.teal, "concluido": false},
    {"id": "1_7", "dia": 1, "horarioInicial": "15:40", "horarioFinal": "16:25", "titulo": "Orientação", "cor": Colors.deepPurple, "concluido": false},
    {"id": "1_8", "dia": 1, "horarioInicial": "16:30", "horarioFinal": "16:50", "titulo": "Tempo Livre", "cor": Colors.blueGrey, "concluido": false},
    {"id": "1_9", "dia": 1, "horarioInicial": "17:00", "horarioFinal": "17:50", "titulo": "Brincadeiras Noite Familiar", "cor": Colors.green, "concluido": false},
    {"id": "1_10", "dia": 1, "horarioInicial": "18:00", "horarioFinal": "18:50", "titulo": "Aula da Noite Familiar", "cor": Colors.deepPurple, "concluido": false},
    {"id": "1_11", "dia": 1, "horarioInicial": "19:00", "horarioFinal": "20:30", "titulo": "Jantar", "cor": Colors.orange, "concluido": false},
    {"id": "1_12", "dia": 1, "horarioInicial": "20:45", "horarioFinal": "21:15", "titulo": "Refletir e Analisar", "cor": Colors.teal, "concluido": false},
    {"id": "1_13", "dia": 1, "horarioInicial": "21:15", "horarioFinal": "22:00", "titulo": "Higiene / Hora do silêncio", "cor": Colors.blueGrey, "concluido": false},
    {"id": "1_14", "dia": 1, "horarioInicial": "22:10", "horarioFinal": "22:20", "titulo": "Apagar as luzes", "cor": Colors.black54, "concluido": false},
    {"id": "2_1", "dia": 2, "horarioInicial": "07:00", "horarioFinal": "08:00", "titulo": "Acordar e preparar", "cor": Colors.blueGrey, "concluido": false},
    {"id": "2_2", "dia": 2, "horarioInicial": "08:00", "horarioFinal": "08:15", "titulo": "Devocional matutino", "cor": Colors.deepPurple, "concluido": false},
    {"id": "2_3", "dia": 2, "horarioInicial": "08:15", "horarioFinal": "09:15", "titulo": "Desjejum", "cor": Colors.orange, "concluido": false},
    {"id": "2_4", "dia": 2, "horarioInicial": "09:30", "horarioFinal": "10:30", "titulo": "Reunião Sacramental", "cor": Colors.deepPurple, "concluido": false},
    {"id": "2_5", "dia": 2, "horarioInicial": "10:40", "horarioFinal": "11:30", "titulo": "Vem, e Segue-me", "cor": Colors.deepPurple, "concluido": false},
    {"id": "2_6", "dia": 2, "horarioInicial": "11:45", "horarioFinal": "12:30", "titulo": "Family Search", "cor": Colors.green, "concluido": false},
    {"id": "2_7", "dia": 2, "horarioInicial": "13:00", "horarioFinal": "14:30", "titulo": "Almoço | Ensaio musical", "cor": Colors.orange, "concluido": false},
    {"id": "2_8", "dia": 2, "horarioInicial": "14:30", "horarioFinal": "15:30", "titulo": "Compartilhar o Evangelho", "cor": Colors.green, "concluido": false},
    {"id": "2_9", "dia": 2, "horarioInicial": "15:40", "horarioFinal": "16:40", "titulo": "Tempo Livre", "cor": Colors.blueGrey, "concluido": false},
    {"id": "2_10", "dia": 2, "horarioInicial": "16:50", "horarioFinal": "17:50", "titulo": "Atividade Força dos Jovens", "cor": Colors.green, "concluido": false},
    {"id": "2_11", "dia": 2, "horarioInicial": "18:00", "horarioFinal": "18:50", "titulo": "Devocional com o Setenta", "cor": Colors.deepPurple, "concluido": false},
    {"id": "2_12", "dia": 2, "horarioInicial": "19:00", "horarioFinal": "20:30", "titulo": "Jantar", "cor": Colors.orange, "concluido": false},
    {"id": "2_13", "dia": 2, "horarioInicial": "20:45", "horarioFinal": "21:15", "titulo": "Refletir e analisar", "cor": Colors.teal, "concluido": false},
    {"id": "2_14", "dia": 2, "horarioInicial": "21:20", "horarioFinal": "22:00", "titulo": "Higiene e Estudo pessoal", "cor": Colors.blueGrey, "concluido": false},
    {"id": "2_15", "dia": 2, "horarioInicial": "22:10", "horarioFinal": "22:20", "titulo": "Apagar as luzes", "cor": Colors.black54, "concluido": false},
    {"id": "3_1", "dia": 3, "horarioInicial": "07:00", "horarioFinal": "08:00", "titulo": "Acordar e preparar", "cor": Colors.blueGrey, "concluido": false},
    {"id": "3_2", "dia": 3, "horarioInicial": "08:00", "horarioFinal": "08:15", "titulo": "Devocional matutino", "cor": Colors.deepPurple, "concluido": false},
    {"id": "3_3", "dia": 3, "horarioInicial": "08:15", "horarioFinal": "09:15", "titulo": "Desjejum", "cor": Colors.orange, "concluido": false},
    {"id": "3_4", "dia": 3, "horarioInicial": "09:25", "horarioFinal": "10:15", "titulo": "Estudo do Vem, e Segue Me", "cor": Colors.deepPurple, "concluido": false},
    {"id": "3_5", "dia": 3, "horarioInicial": "10:30", "horarioFinal": "11:15", "titulo": "Preparação gritos de guerra", "cor": Colors.green, "concluido": false},
    {"id": "3_6", "dia": 3, "horarioInicial": "11:10", "horarioFinal": "12:20", "titulo": "Manhã de jogos", "cor": Colors.green, "concluido": false},
    {"id": "3_7", "dia": 3, "horarioInicial": "12:30", "horarioFinal": "13:50", "titulo": "Almoço | Teste Show", "cor": Colors.orange, "concluido": false},
    {"id": "3_8", "dia": 3, "horarioInicial": "14:00", "horarioFinal": "14:50", "titulo": "Serão Vespertino Casal", "cor": Colors.deepPurple, "concluido": false},
    {"id": "3_9", "dia": 3, "horarioInicial": "15:00", "horarioFinal": "15:50", "titulo": "Atividade Viver o Evangelho", "cor": Colors.green, "concluido": false},
    {"id": "3_10", "dia": 3, "horarioInicial": "16:00", "horarioFinal": "16:40", "titulo": "FSY Humano", "cor": Colors.green, "concluido": false},
    {"id": "3_11", "dia": 3, "horarioInicial": "16:50", "horarioFinal": "17:50", "titulo": "Normas de etiqueta / Banho", "cor": Colors.blueGrey, "concluido": false},
    {"id": "3_12", "dia": 3, "horarioInicial": "18:00", "horarioFinal": "19:00", "titulo": "Jantar", "cor": Colors.orange, "concluido": false},
    {"id": "3_13", "dia": 3, "horarioInicial": "19:00", "horarioFinal": "21:00", "titulo": "Baile + Lanche", "cor": Colors.green, "concluido": false},
    {"id": "3_14", "dia": 3, "horarioInicial": "21:15", "horarioFinal": "21:45", "titulo": "Refletir e Analisar", "cor": Colors.teal, "concluido": false},
    {"id": "3_15", "dia": 3, "horarioInicial": "21:45", "horarioFinal": "22:30", "titulo": "Hora do silêncio", "cor": Colors.blueGrey, "concluido": false},
    {"id": "3_16", "dia": 3, "horarioInicial": "22:30", "horarioFinal": "22:40", "titulo": "Apagar as luzes", "cor": Colors.black54, "concluido": false},
    {"id": "4_1", "dia": 4, "horarioInicial": "07:00", "horarioFinal": "08:00", "titulo": "Acordar e preparar", "cor": Colors.blueGrey, "concluido": false},
    {"id": "4_2", "dia": 4, "horarioInicial": "08:00", "horarioFinal": "08:15", "titulo": "Devocional matutino", "cor": Colors.deepPurple, "concluido": false},
    {"id": "4_3", "dia": 4, "horarioInicial": "08:15", "horarioFinal": "09:15", "titulo": "Desjejum", "cor": Colors.orange, "concluido": false},
    {"id": "4_4", "dia": 4, "horarioInicial": "09:25", "horarioFinal": "09:45", "titulo": "Estudo Vem e segue-Me", "cor": Colors.deepPurple, "concluido": false},
    {"id": "4_5", "dia": 4, "horarioInicial": "10:00", "horarioFinal": "11:00", "titulo": "Ensaio Show / Tempo Livre", "cor": Colors.green, "concluido": false},
    {"id": "4_6", "dia": 4, "horarioInicial": "11:10", "horarioFinal": "12:30", "titulo": "Show de Variedades", "cor": Colors.green, "concluido": false},
    {"id": "4_7", "dia": 4, "horarioInicial": "12:40", "horarioFinal": "14:00", "titulo": "Almoço / Trocar de roupa", "cor": Colors.orange, "concluido": false},
    {"id": "4_8", "dia": 4, "horarioInicial": "14:00", "horarioFinal": "15:00", "titulo": "Serão Rapazes / A Família", "cor": Colors.deepPurple, "concluido": false},
    {"id": "4_9", "dia": 4, "horarioInicial": "15:20", "horarioFinal": "16:20", "titulo": "Serão Moças / A Família", "cor": Colors.deepPurple, "concluido": false},
    {"id": "4_10", "dia": 4, "horarioInicial": "16:30", "horarioFinal": "17:50", "titulo": "Ensaio Musical / Tempo", "cor": Colors.blueGrey, "concluido": false},
    {"id": "4_11", "dia": 4, "horarioInicial": "18:00", "horarioFinal": "19:00", "titulo": "Jantar", "cor": Colors.orange, "concluido": false},
    {"id": "4_12", "dia": 4, "horarioInicial": "19:10", "horarioFinal": "20:20", "titulo": "Programa Musical e Dev", "cor": Colors.deepPurple, "concluido": false},
    {"id": "4_13", "dia": 4, "horarioInicial": "20:30", "horarioFinal": "21:30", "titulo": "Reunião de Testemunhos", "cor": Colors.deepPurple, "concluido": false},
    {"id": "4_14", "dia": 4, "horarioInicial": "21:40", "horarioFinal": "22:00", "titulo": "Refletir e Analisar", "cor": Colors.teal, "concluido": false},
    {"id": "4_15", "dia": 4, "horarioInicial": "22:00", "horarioFinal": "22:30", "titulo": "Hora silêncio e preparação", "cor": Colors.blueGrey, "concluido": false},
    {"id": "4_16", "dia": 4, "horarioInicial": "22:40", "horarioFinal": "22:50", "titulo": "Apagar as luzes", "cor": Colors.black54, "concluido": false},
    {"id": "5_1", "dia": 5, "horarioInicial": "07:00", "horarioFinal": "08:00", "titulo": "Acordar e preparar", "cor": Colors.blueGrey, "concluido": false},
    {"id": "5_2", "dia": 5, "horarioInicial": "08:00", "horarioFinal": "08:15", "titulo": "Devocional matutino", "cor": Colors.deepPurple, "concluido": false},
    {"id": "5_3", "dia": 5, "horarioInicial": "08:20", "horarioFinal": "09:20", "titulo": "Desjejum", "cor": Colors.orange, "concluido": false},
    {"id": "5_4", "dia": 5, "horarioInicial": "09:30", "horarioFinal": "10:10", "titulo": "Atividade Conecte-se", "cor": Colors.green, "concluido": false},
    {"id": "5_5", "dia": 5, "horarioInicial": "10:25", "horarioFinal": "10:40", "titulo": "Apresentação de Slides", "cor": Colors.blueGrey, "concluido": false},
    {"id": "5_6", "dia": 5, "horarioInicial": "10:40", "horarioFinal": "11:40", "titulo": "Devocional O que vou levar", "cor": Colors.deepPurple, "concluido": false},
    {"id": "5_7", "dia": 5, "horarioInicial": "11:50", "horarioFinal": "12:30", "titulo": "Refletir em Companhia", "cor": Colors.teal, "concluido": false},
    {"id": "5_8", "dia": 5, "horarioInicial": "12:30", "horarioFinal": "13:40", "titulo": "Almoço / Arrumar as malas", "cor": Colors.orange, "concluido": false},
    {"id": "5_9", "dia": 5, "horarioInicial": "14:00", "horarioFinal": "15:00", "titulo": "Saída dos Participantes", "cor": Colors.blueGrey, "concluido": false},
  ];

  // Banco centralizado (simulando o banco de dados geral)
  final List<Map<String, String>> _bancoJovensGeral = [
    {"nome": "João Silva", "idade": "16 anos", "quarto": "Bloco B - 204", "restricoes": "Nenhuma", "obs": "Gosta muito de tocar violão.", "foto": "J", "consultor": "Consultor Teste"},
    {"nome": "Lucas Almeida", "idade": "17 anos", "quarto": "Bloco B - 204", "restricoes": "Intolerância à Lactose", "obs": "Um pouco tímido, trazer para as conversas.", "foto": "L", "consultor": "Consultor Teste"},
    {"nome": "Pedro Costa", "idade": "15 anos", "quarto": "Bloco B - 205", "restricoes": "Alergia a Amendoim", "obs": "Líder natural, ótimo para puxar o grito de guerra.", "foto": "P", "consultor": "Consultor Teste"},
    {"nome": "Ana Clara", "idade": "15 anos", "quarto": "Bloco A - 101", "restricoes": "Nenhuma", "obs": "Excelente cantora.", "foto": "A", "consultor": "Outra Pessoa"},
  ];

  // Esta será a lista final apresentada na tela após o filtro
  List<Map<String, String>> _meusJovensFiltrados = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosBase(); 
    _sincronizarComAgenda();
    
    _relogio = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      if (mounted) {
        _sincronizarComAgenda(); 
        setState(() { _horaAtual = DateTime.now(); });
      }
    });
  }

  @override
  void dispose() {
    _relogio?.cancel();
    super.dispose();
  }

  // --- BUSCA DADOS LOCAIS E FILTRA OS JOVENS ---
  Future<void> _carregarDadosBase() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notasController.text = prefs.getString('notas_consultor') ?? "";
      _generoConsultor = prefs.getString('perfil_genero') ?? "Masculino";
      _nomeConsultorLogado = prefs.getString('perfil_nome') ?? "Consultor Teste";
      _funcaoLogada = prefs.getString('perfil_funcao') ?? "Consultor";

      // Filtra os jovens: Apenas quem pertence a este consultor aparece!
      if (_funcaoLogada != 'Administrador') {
        _meusJovensFiltrados = _bancoJovensGeral
            .where((jovem) => jovem['consultor'] == _nomeConsultorLogado)
            .toList();
      } else {
        _meusJovensFiltrados = []; // O Admin não possui jovens diretos
      }
    });
  }

  Future<void> _salvarNotas(String texto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notas_consultor', texto);
  }

  Future<void> _sincronizarComAgenda() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _diaAtual = prefs.getInt('diaSalvo') ?? 1; });
    final String? modJson = prefs.getString('eventos_modificados');
    if (modJson != null) {
      Map<String, dynamic> mods = jsonDecode(modJson);
      for (var e in _todosEventos) {
        if (mods.containsKey(e["id"])) {
          e["horarioInicial"] = mods[e["id"]]["horarioInicial"];
          e["horarioFinal"] = mods[e["id"]]["horarioFinal"];
        }
      }
    }
  }

  int _horaParaMin(String h) => int.parse(h.split(":")[0]) * 60 + int.parse(h.split(":")[1]);

  void _abrirFichaDoJovem(Map<String, String> jovem, bool isEscuro, Color corTema) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      backgroundColor: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              
              CircleAvatar(
                radius: 40, 
                backgroundColor: corTema.withValues(alpha: 0.2), 
                child: Text(jovem["foto"]!, style: TextStyle(fontSize: 35, color: corTema, fontWeight: FontWeight.bold))
              ),
              const SizedBox(height: 15),
              
              Text(jovem["nome"]!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(jovem["idade"]!, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 25),
              
              Card(
                elevation: 0, color: isEscuro ? Colors.black26 : Colors.grey.shade100, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      _linhaDeInformacao(Icons.hotel, "Alojamento", jovem["quarto"]!, corTema),
                      const Divider(),
                      _linhaDeInformacao(Icons.warning_amber_rounded, "Saúde/Dieta", jovem["restricoes"]!, Colors.orange),
                      const Divider(),
                      _linhaDeInformacao(Icons.edit_note, "Observação", jovem["obs"]!, Colors.green),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _linhaDeInformacao(IconData icone, String titulo, String valor, Color cor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: cor, size: 24),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;
    Color corTextoSecundario = isEscuro ? Colors.white70 : Colors.black54;

    // --- LÓGICA DE GÉNERO ---
    String tituloJovens = "Meus Jovens";
    Color corIconeJovens = Colors.blue;
    IconData iconeJovens = Icons.people;

    if (_generoConsultor.toLowerCase().contains("fem") || _generoConsultor.toLowerCase().contains("mulher")) {
      tituloJovens = "Minhas Moças";
      corIconeJovens = Colors.pinkAccent;
      iconeJovens = Icons.face_3; 
    } else if (_generoConsultor.toLowerCase().contains("masc") || _generoConsultor.toLowerCase().contains("homem")) {
      tituloJovens = "Meus Rapazes";
      corIconeJovens = Colors.blue;
      iconeJovens = Icons.face; 
    }

    // --- LÓGICA DO RELÓGIO DA AGENDA ---
    int minAgora = _horaAtual.hour * 60 + _horaAtual.minute;
    Map<String, dynamic>? eventoAgora;
    Map<String, dynamic>? eventoProximo;

    List<Map<String, dynamic>> eventosDoDia = _todosEventos.where((e) => e["dia"] == _diaAtual).toList();

    for (var e in eventosDoDia) {
      int inicio = _horaParaMin(e["horarioInicial"]);
      int fim = _horaParaMin(e["horarioFinal"]);

      if (minAgora >= inicio && minAgora < fim) {
        eventoAgora = e;
      } else if (minAgora < inicio && eventoProximo == null) {
        eventoProximo = e;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Agenda (Sincronizada: Dia $_diaAtual)", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                "${_horaAtual.hour.toString().padLeft(2, '0')}:${_horaAtual.minute.toString().padLeft(2, '0')}", 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)
              ),
            ],
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: eventoAgora != null 
                  ? _construirBloco("EVENTO ATUAL", eventoAgora, Colors.orange, Colors.deepOrangeAccent, Icons.play_circle_fill)
                  : _construirBlocoVazio("TEMPO LIVRE", "Nenhuma atividade a decorrer agora.", Colors.grey),
              ),
              const SizedBox(width: 15), 
              Expanded(
                child: eventoProximo != null 
                  ? _construirBloco("PRÓXIMO EVENTO", eventoProximo, Colors.lightBlue, Colors.blueAccent, Icons.update)
                  : _construirBlocoVazio("DIA CONCLUÍDO", "Bom descanso para amanhã!", Colors.indigo),
              ),
            ],
          ),
          const SizedBox(height: 35),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Anotações", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(Icons.edit_note, color: corTextoSecundario),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: isEscuro ? const Color(0xFF2A2A2A) : const Color(0xFFFFF9C4), borderRadius: BorderRadius.circular(12), border: Border.all(color: isEscuro ? Colors.white12 : Colors.yellow.shade600, width: 1)),
            child: TextField(
              controller: _notasController, maxLines: 4, onChanged: _salvarNotas, style: TextStyle(fontSize: 15, color: isEscuro ? Colors.white : Colors.black87),
              decoration: InputDecoration(hintText: "Escreva aqui os avisos, impressões ou lembretes...", hintStyle: TextStyle(color: isEscuro ? Colors.white30 : Colors.black38), border: InputBorder.none, contentPadding: const EdgeInsets.all(15)),
            ),
          ),
          const SizedBox(height: 30),

          // ==========================================
          // A NOVA LISTA DINÂMICA DE JOVENS NA ABA INICIAL
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(iconeJovens, color: corIconeJovens, size: 22),
                  const SizedBox(width: 8),
                  Text(tituloJovens, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          if (_funcaoLogada == 'Administrador')
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("Como Administrador, você não possui jovens diretos. Utilize a aba Liderança para gerenciar todos.", style: TextStyle(fontStyle: FontStyle.italic)),
            )
          else if (_meusJovensFiltrados.isEmpty)
             const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("Nenhum jovem associado a você ainda. A liderança fará a alocação em breve."),
            )
          else
            ..._meusJovensFiltrados.map((jovem) {
              return Card(
                elevation: 0, margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)), color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: corIconeJovens.withValues(alpha: 0.15),
                    child: Text(jovem["foto"]!, style: TextStyle(color: corIconeJovens, fontWeight: FontWeight.bold))
                  ),
                  title: Text(jovem["nome"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(jovem["quarto"]!, style: TextStyle(color: corTextoSecundario, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  
                  // Abre a ficha interativa com os detalhes completos!
                  onTap: () => _abrirFichaDoJovem(jovem, isEscuro, corIconeJovens),
                ),
              );
            }),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _construirBloco(String tituloCard, Map<String, dynamic> evento, Color corPrincipal, Color corSecundaria, IconData icone) {
    return GestureDetector(
      onTap: widget.irParaAgenda, 
      child: Container(
        height: 160, padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [corPrincipal, corSecundaria], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: corPrincipal.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Icon(icone, color: Colors.white, size: 16)),
              const SizedBox(width: 8),
              Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(tituloCard, textAlign: TextAlign.center, style: TextStyle(color: corSecundaria, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)))),
            ]),
            const Spacer(),
            Text(evento["titulo"], maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, height: 1.1)),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.access_time, color: Colors.white, size: 12), const SizedBox(width: 4), Text("${evento["horarioInicial"]} - ${evento["horarioFinal"]}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))])),
          ],
        ),
      ),
    );
  }

  Widget _construirBlocoVazio(String tituloCard, String mensagem, Color corFundo) {
    return GestureDetector(
      onTap: widget.irParaAgenda,
      child: Container(
        height: 160, padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: corFundo.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(tituloCard, style: TextStyle(color: corFundo, fontSize: 9, fontWeight: FontWeight.bold))),
            const SizedBox(height: 15), const Icon(Icons.check_circle_outline, color: Colors.white70, size: 30), const SizedBox(height: 8), Text(mensagem, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}