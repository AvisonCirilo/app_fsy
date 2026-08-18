import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class AbaAgenda extends StatefulWidget {
  const AbaAgenda({super.key});
  @override State<AbaAgenda> createState() => _AbaAgendaState();
}

class _AbaAgendaState extends State<AbaAgenda> {
  final List<GlobalKey> _stackKeys = List.generate(6, (index) => GlobalKey());
  final List<String> _dias = ["Dia 0", "Dia 1", "Dia 2", "Dia 3", "Dia 4", "Dia 5"];
  
  int _diaSelecionado = 1;
  late PageController _pageController;
  bool _carregando = true;
  String? _eventoSelecionadoId;
  Timer? _relogioAgenda;
  
  // NOVO: Controlador de Scroll Global
  final ScrollController _scrollController = ScrollController();

  final int _horaInicio = 6, _minutoInicio = 30;
  double _alturaPorMinuto = 1.3, _alturaEscalaInicial = 1.3;

  final List<String> _horariosFixos = [
    for (int h = 6; h <= 23; h++) for (int m = 0; m < 60; m += 15)
      if ((h > 6 || m >= 30) && (h < 23 || m == 0)) "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}",
  ];

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

  @override void initState() {
    super.initState();
    _pageController = PageController(initialPage: _diaSelecionado);
    _carregarDados();
    _relogioAgenda = Timer.periodic(const Duration(minutes: 1), (t) => mounted ? setState(() {}) : null);
    
    // NOVO: Chama a animação para a hora atual logo após a tela carregar!
    WidgetsBinding.instance.addPostFrameCallback((_) => _irParaHoraAtual());
  }

  @override void dispose() {
    _relogioAgenda?.cancel();
    _pageController.dispose();
    _scrollController.dispose(); // Desliga o controlador visual
    super.dispose();
  }

  // LÓGICA DO AUTO-SCROLL
  void _irParaHoraAtual() {
    final agora = DateTime.now();
    int minAgora = (agora.hour * 60) + agora.minute;
    int minGrade = (_horaInicio * 60) + _minutoInicio;
    
    if (minAgora >= minGrade) {
      // Calcula onde a linha laranja está
      double posicaoY = (minAgora - minGrade) * _alturaPorMinuto;
      // Sobe a câmera 150 pixels para a linha ficar no centro e não colada ao topo
      double scrollIdeal = posicaoY - 150;
      if (scrollIdeal < 0) scrollIdeal = 0;
      
      // Animação suave para deslizar a tela sozinha
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            scrollIdeal,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _diaSelecionado = prefs.getInt('diaSalvo') ?? 1);
    _pageController = PageController(initialPage: _diaSelecionado);
    final modJson = prefs.getString('eventos_modificados');
    if (modJson != null) {
      Map<String, dynamic> mods = jsonDecode(modJson);
      for (var e in _todosEventos) {
        if (mods.containsKey(e["id"])) {
        e["horarioInicial"] = mods[e["id"]]["horarioInicial"];
        e["horarioFinal"] = mods[e["id"]]["horarioFinal"];
        e["concluido"] = mods[e["id"]]["concluido"];
      }
      }
    }
    setState(() => _carregando = false);
  }

  Future<void> _salvarModificacoes() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> mods = {for (var e in _todosEventos) e["id"]: {"horarioInicial": e["horarioInicial"], "horarioFinal": e["horarioFinal"], "concluido": e["concluido"]}};
    await prefs.setString('eventos_modificados', jsonEncode(mods));
  }

  Future<void> _salvarDia(int dia) async => (await SharedPreferences.getInstance()).setInt('diaSalvo', dia);

  int _horaParaMin(String h) => int.parse(h.split(":")[0]) * 60 + int.parse(h.split(":")[1]);
  String _minParaHora(int m) => "${((m ~/ 60) % 24).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}";

  void _moverEvento(Map<String, dynamic> e, double y) {
    setState(() {
      int duracao = _horaParaMin(e["horarioFinal"]) - _horaParaMin(e["horarioInicial"]);
      int minFinais = (_horaInicio * 60 + _minutoInicio) + ((y / _alturaPorMinuto) / 15).round() * 15;
      e["horarioInicial"] = _minParaHora(minFinais); e["horarioFinal"] = _minParaHora(minFinais + duracao);
      _eventoSelecionadoId = e["id"];
    });
    _salvarModificacoes();
  }

  void _redimensionar(Map<String, dynamic> e, double dy, bool isTopo) {
    setState(() {
      String key = isTopo ? "_minInicioF" : "_minFimF";
      e[key] ??= _horaParaMin(isTopo ? e["horarioInicial"] : e["horarioFinal"]).toDouble();
      e[key] += dy / _alturaPorMinuto;
      int novoVal = e[key].round(), oposto = _horaParaMin(isTopo ? e["horarioFinal"] : e["horarioInicial"]);
      
      if (isTopo) {
        if (novoVal > oposto - 15) novoVal = oposto - 15;
        if (novoVal < (_horaInicio * 60 + _minutoInicio)) novoVal = _horaInicio * 60 + _minutoInicio;
        e["horarioInicial"] = _minParaHora(novoVal);
      } else {
        if (novoVal < oposto + 15) novoVal = oposto + 15;
        if (novoVal > 23 * 60 + 59) novoVal = 23 * 60 + 59;
        e["horarioFinal"] = _minParaHora(novoVal);
      }
      e[key] = novoVal.toDouble();
    });
  }

  void _fimRedimensionar(Map<String, dynamic> e) {
    setState(() {
      e["horarioInicial"] = _minParaHora((_horaParaMin(e["horarioInicial"]) / 15).round() * 15);
      e["horarioFinal"] = _minParaHora((_horaParaMin(e["horarioFinal"]) / 15).round() * 15);
      e.remove("_minInicioF"); e.remove("_minFimF");
    });
    _salvarModificacoes();
  }

  Widget _b(Map<String, dynamic> e, bool isTopo) => Positioned(
    top: isTopo ? -5 : null, bottom: !isTopo ? -5 : null, left: 0, right: 0,
    child: GestureDetector(
      onVerticalDragUpdate: (d) => _redimensionar(e, d.delta.dy, isTopo),
      onVerticalDragEnd: (_) => _fimRedimensionar(e),
      child: Container(height: 20, alignment: isTopo ? Alignment.topCenter : Alignment.bottomCenter, color: Colors.transparent,
        child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white, shape: BoxShape.circle, border: Border.all(color: e["cor"], width: 2)))),
  ));

  Widget _cartao(Map<String, dynamic> evento, double alt) {
    bool isSel = _eventoSelecionadoId == evento["id"], isEsc = Theme.of(context).brightness == Brightness.dark;
    return Stack(clipBehavior: Clip.none, children: [
      GestureDetector(
        onTap: () => setState(() => _eventoSelecionadoId = evento["id"]),
        child: Container(
          height: alt,
          decoration: BoxDecoration(color: evento["cor"].withValues(alpha: isEsc ? 0.25 : 0.15), borderRadius: const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
            border: Border(left: BorderSide(color: evento["cor"], width: 4), top: isSel ? BorderSide(color: evento["cor"], width: 1.5) : BorderSide.none, bottom: isSel ? BorderSide(color: evento["cor"], width: 1.5) : BorderSide.none, right: isSel ? BorderSide(color: evento["cor"], width: 1.5) : BorderSide.none)),
          child: Row(children: [
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(evento["titulo"], maxLines: alt < 30 ? 1 : 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: alt < 25 ? 11 : 13, decoration: evento["concluido"] ? TextDecoration.lineThrough : TextDecoration.none, color: evento["concluido"] ? Colors.grey : (isEsc ? Colors.white : Colors.black87))),
              if (alt >= 35) Text("${evento["horarioInicial"]} - ${evento["horarioFinal"]}", style: TextStyle(fontSize: 11, color: isEsc ? Colors.white60 : Colors.black54)),
            ]))),
            if (alt >= 20) Transform.scale(scale: alt < 35 ? 0.6 : 0.9, child: Checkbox(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact, value: evento["concluido"], activeColor: evento["cor"], onChanged: (v) { setState(() => evento["concluido"] = v!); _salvarModificacoes(); }))
          ]),
        ),
      ),
      if (isSel) _b(evento, true), if (isSel) _b(evento, false),
    ]);
  }

  @override Widget build(BuildContext context) {
    if (_carregando) return const Center(child: CircularProgressIndicator(color: Colors.blue));
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;
    
    // NOVO: Altura total matemática exata da grelha de horários (para o scroll global)
    double alturaTotalGrade = _horariosFixos.length * 15 * _alturaPorMinuto;

    return Column(children: [
      Container(
        height: 60, decoration: BoxDecoration(color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3, offset: const Offset(0, 2))]),
        child: Row(children: List.generate(_dias.length, (i) {
          bool isSel = _diaSelecionado == i;
          return Expanded(child: GestureDetector(
            onTap: () { setState(() { _diaSelecionado = i; _eventoSelecionadoId = null; }); _salvarDia(i); _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); },
            child: Container(alignment: Alignment.center, decoration: BoxDecoration(border: isSel ? const Border(bottom: BorderSide(color: Colors.blue, width: 3)) : null), child: Text(_dias[i], style: TextStyle(fontSize: 14, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.blue : (isEscuro ? Colors.white60 : Colors.black54)))),
          ));
        })),
      ),
      
      // A MAGIA ACONTECE AQUI: O ScrollVertical Global envolve a PageView!
      Expanded(
        child: GestureDetector(
          onScaleStart: (d) { if (d.pointerCount == 2) _alturaEscalaInicial = _alturaPorMinuto; },
          onScaleUpdate: (d) { if (d.pointerCount == 2) setState(() => _alturaPorMinuto = (_alturaEscalaInicial * d.scale).clamp(1.0, 4.0)); },
          child: SingleChildScrollView(
            controller: _scrollController, // Injeta o controlador de Scroll
            padding: const EdgeInsets.only(bottom: 50, top: 15),
            child: SizedBox(
              height: alturaTotalGrade, // Obriga a PageView a ter o tamanho total da Agenda
              child: PageView.builder(
                controller: _pageController, itemCount: _dias.length,
                onPageChanged: (i) { setState(() { _diaSelecionado = i; _eventoSelecionadoId = null; }); _salvarDia(i); },
                itemBuilder: (ctx, pIndex) => Stack(key: _stackKeys[pIndex], children: [
                  Column(children: _horariosFixos.map((h) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 55, height: 15 * _alturaPorMinuto, child: h.endsWith(":00") ? Transform.translate(offset: const Offset(0, -8), child: Text(h, style: TextStyle(fontWeight: FontWeight.bold, color: isEscuro ? Colors.white60 : Colors.black54, fontSize: 13), textAlign: TextAlign.center)) : null),
                    Expanded(child: Container(height: 15 * _alturaPorMinuto, decoration: BoxDecoration(border: Border(top: BorderSide(color: h.endsWith(":00") ? (isEscuro ? Colors.white12 : Colors.grey.shade300) : Colors.transparent, width: 1)))))
                  ])).toList()),
                  Positioned.fill(child: DragTarget<Map<String, dynamic>>(
                    onAcceptWithDetails: (d) => _moverEvento(d.data, ((_stackKeys[pIndex].currentContext!.findRenderObject() as RenderBox).globalToLocal(d.offset).dy < 0 ? 0 : (_stackKeys[pIndex].currentContext!.findRenderObject() as RenderBox).globalToLocal(d.offset).dy)),
                    builder: (ctx, _, _) => GestureDetector(onTap: () => setState(() => _eventoSelecionadoId = null), child: Container(color: Colors.transparent))
                  )),
                  ..._todosEventos.where((e) => e["dia"] == pIndex).map((e) {
                    int mIn = _horaParaMin(e["horarioInicial"]), mFim = _horaParaMin(e["horarioFinal"]);
                    double pos = (mIn - (_horaInicio * 60 + _minutoInicio)) * _alturaPorMinuto, alt = (mFim - mIn) * _alturaPorMinuto;
                    return Positioned(top: pos, left: 55, right: 10, height: alt < 35 ? 35 : alt,
                      child: LongPressDraggable<Map<String, dynamic>>(data: e, onDragStarted: () => setState(() => _eventoSelecionadoId = e["id"]), feedback: Material(color: Colors.transparent, child: Opacity(opacity: 0.8, child: SizedBox(width: MediaQuery.of(context).size.width - 65, height: alt < 35 ? 35 : alt, child: _cartao(e, alt < 35 ? 35 : alt)))), childWhenDragging: Opacity(opacity: 0.3, child: _cartao(e, alt < 35 ? 35 : alt)), child: _cartao(e, alt < 35 ? 35 : alt)));
                  }),
                  Builder(builder: (ctx) {
                    final agora = DateTime.now(); int minAgora = (agora.hour * 60) + agora.minute, minGrade = (_horaInicio * 60) + _minutoInicio;
                    if (minAgora >= minGrade) return Positioned(top: ((minAgora - minGrade) * _alturaPorMinuto) - 4, left: 45, right: 0, child: Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5))), Expanded(child: Container(height: 2, color: Colors.deepOrange.withValues(alpha: 0.7)))]));
                    return const SizedBox.shrink();
                  }),
                ]),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}