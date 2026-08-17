import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbaAgenda extends StatefulWidget {
  const AbaAgenda({super.key});

  @override
  State<AbaAgenda> createState() => _AbaAgendaState();
}

class _AbaAgendaState extends State<AbaAgenda> {
  final List<GlobalKey> _stackKeys = List.generate(6, (index) => GlobalKey());
  final List<String> _dias = ["Dia 0", "Dia 1", "Dia 2", "Dia 3", "Dia 4", "Dia 5"];
  
  int _diaSelecionado = 1;
  late PageController _pageController;
  bool _carregando = true; 

  String? _eventoSelecionadoId;

  final int _horaInicio = 6;
  final int _minutoInicio = 30;
  double _alturaPorMinuto = 1.3; 
  double _alturaEscalaInicial = 1.3; 

  final List<String> _horariosFixos = [
    for (int h = 6; h <= 23; h++)
      for (int m = 0; m < 60; m += 15)
        if ((h > 6 || m >= 30) && (h < 23 || m == 0)) 
          "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}"
  ];

  // ==========================================
  // BANCO DE DADOS OFICIAL DO FSY
  // ==========================================
  final List<Map<String, dynamic>> _todosEventos = [
    {"id": "0_1", "dia": 0, "horarioInicial": "19:00", "horarioFinal": "20:00", "titulo": "Mensagem do casal diretor da sessão", "cor": Colors.deepPurple, "concluido": false},
    {"id": "0_2", "dia": 0, "horarioInicial": "20:15", "horarioFinal": "21:15", "titulo": "Reuniões CA e Consultores", "cor": Colors.deepPurple, "concluido": false},
    {"id": "0_3", "dia": 0, "horarioInicial": "21:20", "horarioFinal": "21:50", "titulo": "Reunião de Coordenadores", "cor": Colors.deepPurple, "concluido": false},
    {"id": "1_1", "dia": 1, "horarioInicial": "07:30", "horarioFinal": "08:20", "titulo": "Desjejum da Equipe", "cor": Colors.orange, "concluido": false},
    {"id": "1_2", "dia": 1, "horarioInicial": "08:30", "horarioFinal": "09:15", "titulo": "Reunião administrativa", "cor": Colors.deepPurple, "concluido": false},
    {"id": "1_3", "dia": 1, "horarioInicial": "09:15", "horarioFinal": "10:45", "titulo": "Distribuição de materiais/Ensaio", "cor": Colors.blueGrey, "concluido": false},
    {"id": "1_4", "dia": 1, "horarioInicial": "11:00", "horarioFinal": "13:00", "titulo": "Check-in / Almoço", "cor": Colors.orange, "concluido": false},
    {"id": "1_5", "dia": 1, "horarioInicial": "13:15", "horarioFinal": "14:00", "titulo": "Conheça seu consultor", "cor": Colors.green, "concluido": false},
    {"id": "1_6", "dia": 1, "horarioInicial": "14:15", "horarioFinal": "15:25", "titulo": "Conheça sua cia + Elaborar Metas", "cor": Colors.teal, "concluido": false},
    {"id": "1_7", "dia": 1, "horarioInicial": "15:40", "horarioFinal": "16:25", "titulo": "Orientação", "cor": Colors.deepPurple, "concluido": false},
    {"id": "1_8", "dia": 1, "horarioInicial": "16:30", "horarioFinal": "16:50", "titulo": "Tempo Livre", "cor": Colors.blueGrey, "concluido": false},
    {"id": "1_9", "dia": 1, "horarioInicial": "17:00", "horarioFinal": "17:50", "titulo": "Brincadeiras da Noite Familiar", "cor": Colors.green, "concluido": false},
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
    {"id": "3_7", "dia": 3, "horarioInicial": "12:30", "horarioFinal": "13:50", "titulo": "Almoço | Teste Show Variedades", "cor": Colors.orange, "concluido": false},
    {"id": "3_8", "dia": 3, "horarioInicial": "14:00", "horarioFinal": "14:50", "titulo": "Serão Vespertino Casal Diretor", "cor": Colors.deepPurple, "concluido": false},
    {"id": "3_9", "dia": 3, "horarioInicial": "15:00", "horarioFinal": "15:50", "titulo": "Atividade Viver o Evangelho", "cor": Colors.green, "concluido": false},
    {"id": "3_10", "dia": 3, "horarioInicial": "16:00", "horarioFinal": "16:40", "titulo": "FSY Humano", "cor": Colors.green, "concluido": false},
    {"id": "3_11", "dia": 3, "horarioInicial": "16:50", "horarioFinal": "17:50", "titulo": "Normas de etiqueta / Banho", "cor": Colors.blueGrey, "concluido": false},
    {"id": "3_12", "dia": 3, "horarioInicial": "18:00", "horarioFinal": "19:00", "titulo": "Jantar", "cor": Colors.orange, "concluido": false},
    {"id": "3_13", "dia": 3, "horarioInicial": "19:00", "horarioFinal": "21:00", "titulo": "Baile + Lanche", "cor": Colors.green, "concluido": false},
    {"id": "3_14", "dia": 3, "horarioInicial": "21:15", "horarioFinal": "21:45", "titulo": "Refletir e Analisar", "cor": Colors.teal, "concluido": false},
    {"id": "3_15", "dia": 3, "horarioInicial": "21:45", "horarioFinal": "22:30", "titulo": "Hora do silêncio / Preparação", "cor": Colors.blueGrey, "concluido": false},
    {"id": "3_16", "dia": 3, "horarioInicial": "22:30", "horarioFinal": "22:40", "titulo": "Apagar as luzes", "cor": Colors.black54, "concluido": false},
    {"id": "4_1", "dia": 4, "horarioInicial": "07:00", "horarioFinal": "08:00", "titulo": "Acordar e preparar", "cor": Colors.blueGrey, "concluido": false},
    {"id": "4_2", "dia": 4, "horarioInicial": "08:00", "horarioFinal": "08:15", "titulo": "Devocional matutino", "cor": Colors.deepPurple, "concluido": false},
    {"id": "4_3", "dia": 4, "horarioInicial": "08:15", "horarioFinal": "09:15", "titulo": "Desjejum", "cor": Colors.orange, "concluido": false},
    {"id": "4_4", "dia": 4, "horarioInicial": "09:25", "horarioFinal": "09:45", "titulo": "Estudo Vem e segue-Me", "cor": Colors.deepPurple, "concluido": false},
    {"id": "4_5", "dia": 4, "horarioInicial": "10:00", "horarioFinal": "11:00", "titulo": "Ensaio Show / Tempo Livre", "cor": Colors.green, "concluido": false},
    {"id": "4_6", "dia": 4, "horarioInicial": "11:10", "horarioFinal": "12:30", "titulo": "Show de Variedades", "cor": Colors.green, "concluido": false},
    {"id": "4_7", "dia": 4, "horarioInicial": "12:40", "horarioFinal": "14:00", "titulo": "Almoço / Trocar de roupa", "cor": Colors.orange, "concluido": false},
    {"id": "4_8", "dia": 4, "horarioInicial": "14:00", "horarioFinal": "15:00", "titulo": "Serão Rapazes / A Família (Moças)", "cor": Colors.deepPurple, "concluido": false},
    {"id": "4_9", "dia": 4, "horarioInicial": "15:20", "horarioFinal": "16:20", "titulo": "Serão Moças / A Família (Rapazes)", "cor": Colors.deepPurple, "concluido": false},
    {"id": "4_10", "dia": 4, "horarioInicial": "16:30", "horarioFinal": "17:50", "titulo": "Ensaio Musical / Tempo Livre", "cor": Colors.blueGrey, "concluido": false},
    {"id": "4_11", "dia": 4, "horarioInicial": "18:00", "horarioFinal": "19:00", "titulo": "Jantar", "cor": Colors.orange, "concluido": false},
    {"id": "4_12", "dia": 4, "horarioInicial": "19:10", "horarioFinal": "20:20", "titulo": "Programa Musical e Devocional", "cor": Colors.deepPurple, "concluido": false},
    {"id": "4_13", "dia": 4, "horarioInicial": "20:30", "horarioFinal": "21:30", "titulo": "Reunião de Testemunhos", "cor": Colors.deepPurple, "concluido": false},
    {"id": "4_14", "dia": 4, "horarioInicial": "21:40", "horarioFinal": "22:00", "titulo": "Refletir e Analisar", "cor": Colors.teal, "concluido": false},
    {"id": "4_15", "dia": 4, "horarioInicial": "22:00", "horarioFinal": "22:30", "titulo": "Hora do silêncio e preparação", "cor": Colors.blueGrey, "concluido": false},
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

  @override
  void initState() {
    super.initState();
    _carregarDiaSalvo();
  }

  Future<void> _carregarDiaSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _diaSelecionado = prefs.getInt('diaSalvo') ?? 1;
      _pageController = PageController(initialPage: _diaSelecionado);
      _carregando = false; 
    });
  }

  Future<void> _salvarDia(int dia) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('diaSalvo', dia);
  }

  int _horaParaMinutos(String horaString) {
    final partes = horaString.split(":");
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }

  String _minutosParaHora(int minutosTotais) {
    int hora = (minutosTotais ~/ 60) % 24;
    int minuto = minutosTotais % 60;
    return "${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}";
  }

  void _moverEventoParaPixel(Map<String, dynamic> evento, double droppedY, int pageIndex) {
    setState(() {
      final mInicioAntigo = _horaParaMinutos(evento["horarioInicial"]);
      final mFimAntigo = _horaParaMinutos(evento["horarioFinal"]);
      final duracaoMins = mFimAntigo - mInicioAntigo;

      double minutosDesdeOTopo = droppedY / _alturaPorMinuto;
      int minutosArredondados = ((minutosDesdeOTopo / 15).round()) * 15;

      int novosMinutosTotais = (_horaInicio * 60 + _minutoInicio) + minutosArredondados;
      int novosMinutosFimTotais = novosMinutosTotais + duracaoMins;
      
      evento["horarioInicial"] = _minutosParaHora(novosMinutosTotais);
      evento["horarioFinal"] = _minutosParaHora(novosMinutosFimTotais);
      
      _eventoSelecionadoId = evento["id"];
    });
  }
  
  void _redimensionarTopo(Map<String, dynamic> evento, double deltaDy) {
    setState(() {
      evento["_minutosInicioFloat"] ??= _horaParaMinutos(evento["horarioInicial"]).toDouble();
      evento["_minutosInicioFloat"] += deltaDy / _alturaPorMinuto;
      
      int mInicioNovo = evento["_minutosInicioFloat"].round();
      int mFim = _horaParaMinutos(evento["horarioFinal"]);
      
      if (mInicioNovo > mFim - 15) {
        mInicioNovo = mFim - 15;
        evento["_minutosInicioFloat"] = mInicioNovo.toDouble();
      }
      int minGrade = _horaInicio * 60 + _minutoInicio;
      if (mInicioNovo < minGrade) {
        mInicioNovo = minGrade;
        evento["_minutosInicioFloat"] = mInicioNovo.toDouble();
      }

      evento["horarioInicial"] = _minutosParaHora(mInicioNovo);
    });
  }

  void _redimensionarBase(Map<String, dynamic> evento, double deltaDy) {
    setState(() {
      evento["_minutosFimFloat"] ??= _horaParaMinutos(evento["horarioFinal"]).toDouble();
      evento["_minutosFimFloat"] += deltaDy / _alturaPorMinuto;
      
      int mFimNovo = evento["_minutosFimFloat"].round();
      int mInicio = _horaParaMinutos(evento["horarioInicial"]);
      
      if (mFimNovo < mInicio + 15) {
        mFimNovo = mInicio + 15;
        evento["_minutosFimFloat"] = mFimNovo.toDouble();
      }
      if (mFimNovo > 23 * 60 + 59) {
        mFimNovo = 23 * 60 + 59;
        evento["_minutosFimFloat"] = mFimNovo.toDouble();
      }

      evento["horarioFinal"] = _minutosParaHora(mFimNovo);
    });
  }

  void _finalizarRedimensionamento(Map<String, dynamic> evento) {
    setState(() {
      int mInicio = _horaParaMinutos(evento["horarioInicial"]);
      int mInicioSnap = (mInicio / 15).round() * 15;
      evento["horarioInicial"] = _minutosParaHora(mInicioSnap);
      evento.remove("_minutosInicioFloat");

      int mFim = _horaParaMinutos(evento["horarioFinal"]);
      int mFimSnap = (mFim / 15).round() * 15;
      evento["horarioFinal"] = _minutosParaHora(mFimSnap);
      evento.remove("_minutosFimFloat");
    });
  }

  // ==========================================
  // CONSTRUÇÃO DO CARTÃO 
  // ==========================================
  Widget _construirCartaoEvento(Map<String, dynamic> evento, double alturaAtual) {
    bool isSelected = _eventoSelecionadoId == evento["id"];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _eventoSelecionadoId = evento["id"];
            });
          },
          child: Container(
            height: alturaAtual,
            decoration: BoxDecoration(
              color: evento["cor"].withValues(alpha: 0.15),
              // REMOVIDO o arredondamento da esquerda para ficar colado perfeitamente!
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
              border: Border(
                left: BorderSide(color: evento["cor"], width: 4),
                top: isSelected ? BorderSide(color: evento["cor"], width: 1.5) : BorderSide.none,
                bottom: isSelected ? BorderSide(color: evento["cor"], width: 1.5) : BorderSide.none,
                right: isSelected ? BorderSide(color: evento["cor"], width: 1.5) : BorderSide.none,
              ),
            ),
            child: ClipRect(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      // Preenchimento ajustado para aproveitar o máximo de espaço sem cortar letras
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            evento["titulo"],
                            maxLines: alturaAtual < 30 ? 1 : 2, // Se for muito fino, usa só 1 linha
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              // Fonte diminui automaticamente em eventos curtos
                              fontSize: alturaAtual < 25 ? 11 : 13,
                              decoration: evento["concluido"] ? TextDecoration.lineThrough : TextDecoration.none,
                              color: evento["concluido"] ? Colors.grey : Colors.black87,
                            ),
                          ),
                          // Só mostra a hora se houver espaço
                          if (alturaAtual >= 35)
                            Text(
                              "${evento["horarioInicial"]} - ${evento["horarioFinal"]}",
                              style: const TextStyle(fontSize: 11, color: Colors.black54),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // A Checkbox só aparece se a altura for minimamente legível (>20px)
                  if (alturaAtual >= 20)
                    Transform.scale(
                      scale: alturaAtual < 35 ? 0.6 : 0.9, 
                      child: Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, 
                        visualDensity: VisualDensity.compact,
                        value: evento["concluido"],
                        activeColor: evento["cor"],
                        onChanged: (bool? valor) => setState(() => evento["concluido"] = valor!),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // BOLINHA DO TOPO (SÓ APARECE SE ESTIVER SELECIONADO)
        if (isSelected)
          Positioned(
            top: -5, left: 0, right: 0, 
            child: GestureDetector(
              onVerticalDragUpdate: (details) => _redimensionarTopo(evento, details.delta.dy),
              onVerticalDragEnd: (details) => _finalizarRedimensionamento(evento),
              child: Container(
                height: 20, 
                alignment: Alignment.topCenter,
                color: Colors.transparent, 
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    shape: BoxShape.circle,
                    border: Border.all(color: evento["cor"], width: 2) 
                  ),
                ),
              ),
            ),
          ),

        // BOLINHA DA BASE (SÓ APARECE SE ESTIVER SELECIONADO)
        if (isSelected)
          Positioned(
            bottom: -5, left: 0, right: 0,
            child: GestureDetector(
              onVerticalDragUpdate: (details) => _redimensionarBase(evento, details.delta.dy),
              onVerticalDragEnd: (details) => _finalizarRedimensionamento(evento),
              child: Container(
                height: 20, 
                alignment: Alignment.bottomCenter,
                color: Colors.transparent,
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    shape: BoxShape.circle,
                    border: Border.all(color: evento["cor"], width: 2)
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Center(child: CircularProgressIndicator(color: Colors.blue));

    return Column(
      children: [
        // BARRA DE DIAS
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: List.generate(_dias.length, (index) {
              bool isSelected = _diaSelecionado == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _diaSelecionado = index;
                      _eventoSelecionadoId = null; 
                    });
                    _salvarDia(index);
                    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  child: Container(
                    decoration: BoxDecoration(border: isSelected ? const Border(bottom: BorderSide(color: Colors.blue, width: 3)) : null),
                    alignment: Alignment.center,
                    child: Text(
                      _dias[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black54,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // PAGEVIEW (DESLIZE DE PÁGINAS)
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _dias.length,
            onPageChanged: (index) {
              setState(() {
                _diaSelecionado = index;
                _eventoSelecionadoId = null; 
              });
              _salvarDia(index);
            },
            itemBuilder: (context, pageIndex) {
              final eventosDestaPagina = _todosEventos.where((e) => e["dia"] == pageIndex).toList();

              return GestureDetector(
                onScaleStart: (details) {
                  if (details.pointerCount == 2) _alturaEscalaInicial = _alturaPorMinuto;
                },
                onScaleUpdate: (details) {
                  if (details.pointerCount == 2) {
                    setState(() => _alturaPorMinuto = (_alturaEscalaInicial * details.scale).clamp(1.0, 4.0));
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 50, top: 15),
                  child: Stack(
                    key: _stackKeys[pageIndex], 
                    children: [
                      // GRADE DE HORÁRIOS DE FUNDO
                      Column(
                        children: _horariosFixos.map((horarioFixo) {
                          bool isHoraCheia = horarioFixo.endsWith(":00");
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 55,
                                height: 15 * _alturaPorMinuto, 
                                child: isHoraCheia
                                    ? Transform.translate(
                                        offset: const Offset(0, -8),
                                        child: Text(
                                          horarioFixo,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : null, 
                              ),
                              Expanded(
                                child: Container(
                                  height: 15 * _alturaPorMinuto,
                                  decoration: BoxDecoration(
                                    border: Border(top: BorderSide(color: isHoraCheia ? Colors.grey.shade300 : Colors.transparent, width: 1)),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),

                      // RECEBEDOR INVISÍVEL (E LIMPADOR DE SELEÇÃO)
                      Positioned.fill(
                        child: DragTarget<Map<String, dynamic>>(
                          onAcceptWithDetails: (details) {
                            final renderBox = _stackKeys[pageIndex].currentContext!.findRenderObject() as RenderBox;
                            final localOffset = renderBox.globalToLocal(details.offset);
                            double droppedY = localOffset.dy;
                            if (droppedY < 0) droppedY = 0; 
                            _moverEventoParaPixel(details.data, droppedY, pageIndex);
                          },
                          builder: (context, candidateData, rejectedData) => GestureDetector(
                            onTap: () {
                              if (_eventoSelecionadoId != null) {
                                setState(() => _eventoSelecionadoId = null);
                              }
                            },
                            child: Container(color: Colors.transparent),
                          ), 
                        ),
                      ),

                      // OS CARTÕES
                      ...eventosDestaPagina.map((evento) {
                        int mInicio = _horaParaMinutos(evento["horarioInicial"]);
                        int mFim = _horaParaMinutos(evento["horarioFinal"]);

                        final double posicaoY = (mInicio - (_horaInicio * 60 + _minutoInicio)) * _alturaPorMinuto;
                        
                        // A MÁGICA FINAL: A altura agora é PURAMENTE matemática! 
                        // Fim das sobreposições forçadas de 35px!
                        double alturaCalculada = (mFim - mInicio) * _alturaPorMinuto;

                        return Positioned(
                          top: posicaoY,
                          left: 55, 
                          right: 10,
                          height: alturaCalculada,
                          child: LongPressDraggable<Map<String, dynamic>>(
                            data: evento,
                            onDragStarted: () {
                              setState(() => _eventoSelecionadoId = evento["id"]);
                            },
                            feedback: Material(
                              color: Colors.transparent,
                              child: Opacity(
                                opacity: 0.8,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 65,
                                  height: alturaCalculada,
                                  child: _construirCartaoEvento(evento, alturaCalculada),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(opacity: 0.3, child: _construirCartaoEvento(evento, alturaCalculada)),
                            child: _construirCartaoEvento(evento, alturaCalculada),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}