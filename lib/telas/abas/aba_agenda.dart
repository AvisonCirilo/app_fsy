import 'package:flutter/material.dart';

class AbaAgenda extends StatefulWidget {
  const AbaAgenda({super.key});

  @override
  State<AbaAgenda> createState() => _AbaAgendaState();
}

class _AbaAgendaState extends State<AbaAgenda> {
  // 1. CHAVE GLOBAL: Para calcularmos a posição exata dos pixels na tela
  final GlobalKey _stackKey = GlobalKey();

  final List<String> _dias = ["Dia 0", "Dia 1", "Dia 2", "Dia 3", "Dia 4", "Dia 5"];
  int _diaSelecionado = 1;

  // --- NOVA CONFIGURAÇÃO DE HORÁRIO E ZOOM ---
  final int _horaInicio = 6;
  final int _minutoInicio = 30;
  
  // O '_alturaPorMinuto' perdeu o 'final' para podermos dar Zoom!
  double _alturaPorMinuto = 2.0; 
  double _alturaEscalaInicial = 2.0; // Guarda a escala inicial do movimento de pinça

  // Gera a régua começando rigorosamente às 06:30 e parando às 23:00
  final List<String> _horariosFixos = [
    for (int h = 6; h <= 23; h++)
      for (int m = 0; m < 60; m += 15)
        if ((h > 6 || m >= 30) && (h < 23 || m == 0)) 
          "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}"
  ];

  // ==========================================
  // BANCO DE DADOS OFICIAL DO FSY (Manual)
  // ==========================================
  final List<Map<String, dynamic>> _todosEventos = [
    // --- DIA ZERO ---
    {"id": "0_1", "dia": 0, "horarioInicial": "19:00", "horarioFinal": "20:00", "titulo": "Mensagem do casal diretor da sessão", "cor": Colors.deepPurple, "concluido": false},
    {"id": "0_2", "dia": 0, "horarioInicial": "20:15", "horarioFinal": "21:15", "titulo": "Reuniões CA e Consultores", "cor": Colors.deepPurple, "concluido": false},
    {"id": "0_3", "dia": 0, "horarioInicial": "21:20", "horarioFinal": "21:50", "titulo": "Reunião de Coordenadores", "cor": Colors.deepPurple, "concluido": false},

    // --- 1º DIA ---
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

    // --- 2º DIA ---
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

    // --- 3º DIA ---
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

    // --- 4º DIA ---
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

    // --- 5º DIA ---
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

  // --- Função Matemática para Atualizar o Horário via Pixel (Encaixe de 15 min) ---
  void _moverEventoParaPixel(Map<String, dynamic> evento, double droppedY) {
    setState(() {
      final inicioOriginal = evento["horarioInicial"].split(":");
      final fimOriginal = evento["horarioFinal"].split(":");
      
      final minutosInicio = int.parse(inicioOriginal[0]) * 60 + int.parse(inicioOriginal[1]);
      final minutosFim = int.parse(fimOriginal[0]) * 60 + int.parse(fimOriginal[1]);
      final duracaoMins = minutosFim - minutosInicio;

      // Descobre quantos minutos tem desde o topo até onde o dedo soltou
      double minutosDesdeOTopo = droppedY / _alturaPorMinuto;
      
      // MÁGICA: Arredonda a posição para o múltiplo de 15 minutos mais próximo!
      int minutosArredondados = ((minutosDesdeOTopo / 15).round()) * 15;

      // Recalcula o horário inicial
      int novosMinutosTotais = (_horaInicio * 60 + _minutoInicio) + minutosArredondados;
      int novaHora = (novosMinutosTotais ~/ 60) % 24;
      int novoMinuto = novosMinutosTotais % 60;
      
      // Recalcula o horário final (preservando a duração original)
      int novosMinutosFimTotais = novosMinutosTotais + duracaoMins;
      int novaHoraFim = (novosMinutosFimTotais ~/ 60) % 24;
      int novoMinutoFim = novosMinutosFimTotais % 60;
      
      evento["horarioInicial"] = "${novaHora.toString().padLeft(2, '0')}:${novoMinuto.toString().padLeft(2, '0')}";
      evento["horarioFinal"] = "${novaHoraFim.toString().padLeft(2, '0')}:${novoMinutoFim.toString().padLeft(2, '0')}";
    });
  }

  Widget _construirCartaoEvento(Map<String, dynamic> evento, double alturaAtual) {
    return Container(
      height: alturaAtual,
      decoration: BoxDecoration(
        color: evento["cor"].withValues(alpha: 0.1), // Mantido seu ajuste de opacidade
        border: Border(left: BorderSide(color: evento["cor"], width: 4)),
      ),
      child: ClipRect( // Mantido seu ajuste de Clip
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10, 
                  vertical: alturaAtual < 35 ? 0 : 2, // Mantido seu ajuste fino de margem
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      evento["titulo"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        decoration: evento["concluido"] ? TextDecoration.lineThrough : TextDecoration.none,
                        color: evento["concluido"] ? Colors.grey : Colors.black87,
                      ),
                    ),
                    if (alturaAtual >= 40)
                      Text(
                        "${evento["horarioInicial"]} - ${evento["horarioFinal"]}",
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                  ],
                ),
              ),
            ),
            
            Transform.scale(
              scale: alturaAtual < 40 ? 0.8 : 1.0, 
              child: Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, 
                visualDensity: VisualDensity.compact,
                value: evento["concluido"],
                activeColor: evento["cor"],
                onChanged: (bool? valor) {
                  setState(() => evento["concluido"] = valor!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtra para exibir apenas os eventos do dia selecionado
    final eventosDoDia = _todosEventos.where((e) => e["dia"] == _diaSelecionado).toList();

    return Column(
      children: [
        // ==========================================
        // 1. BARRA DE DIAS DA SEMANA
        // ==========================================
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.grey.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: List.generate(_dias.length, (index) {
              bool isSelected = _diaSelecionado == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _diaSelecionado = index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: isSelected ? const Border(bottom: BorderSide(color: Colors.blue, width: 3)) : null,
                    ),
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

        // ==========================================
        // 2. TIMELINE COM ZOOM (PINÇA) E ARRASTE DE 15 MIN
        // ==========================================
        Expanded(
          // --- DETECTOR DO MOVIMENTO DE PINÇA ---
          child: GestureDetector(
            onScaleStart: (details) {
              // Ativa apenas se o usuário encostar 2 dedos na tela
              if (details.pointerCount == 2) {
                _alturaEscalaInicial = _alturaPorMinuto;
              }
            },
            onScaleUpdate: (details) {
              if (details.pointerCount == 2) {
                setState(() {
                  // Ajusta o Zoom, mas trava entre 1.0 e 4.0 para não estourar a tela
                  _alturaPorMinuto = (_alturaEscalaInicial * details.scale).clamp(1.0, 4.0);
                });
              }
            },

            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 50, top: 15),
              child: Stack(
                key: _stackKey, 
                children: [
                  
                  // --- CAMADA DE FUNDO: Linhas e Horários ---
                  Column(
                    children: _horariosFixos.map((horarioFixo) {
                      bool isHoraCheia = horarioFixo.endsWith(":00");
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 55,
                            height: 15 * _alturaPorMinuto, // Altura responde ao Zoom!
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
                                border: Border(
                                  top: BorderSide(
                                    color: isHoraCheia ? Colors.grey.shade300 : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),

                  // --- CAMADA DO MEIO: O Alvo Recebedor do Drag & Drop ---
                  Positioned.fill(
                    child: DragTarget<Map<String, dynamic>>(
                      onAcceptWithDetails: (details) {
                        // Descobre exatamente onde o cartão foi solto na tela
                        final renderBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
                        final localOffset = renderBox.globalToLocal(details.offset);
                        
                        double droppedY = localOffset.dy;
                        if (droppedY < 0) droppedY = 0; 
                        
                        // Envia os pixels para a nossa função matemática converter em horário
                        _moverEventoParaPixel(details.data, droppedY);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(color: Colors.transparent); 
                      },
                    ),
                  ),

                  // --- CAMADA DE CIMA: Os Cartões do FSY Animados ---
                  ...eventosDoDia.map((evento) {
                    final inicio = evento["horarioInicial"].split(":");
                    final fim = evento["horarioFinal"].split(":");
                    final hInicio = int.parse(inicio[0]);
                    final mInicio = int.parse(inicio[1]);
                    final hFim = int.parse(fim[0]);
                    final mFim = int.parse(fim[1]);

                    final int minDesdeInicioDoDia = (hInicio * 60 + mInicio) - (_horaInicio * 60 + _minutoInicio);
                    final double posicaoY = minDesdeInicioDoDia * _alturaPorMinuto;

                    final int duracaoMinutos = (hFim * 60 + mFim) - (hInicio * 60 + mInicio);
                    double alturaCalculada = duracaoMinutos * _alturaPorMinuto;

                    // Sua regra de segurança para cartões pequenos:
                    if (alturaCalculada < 35) {
                      alturaCalculada = 35.0;
                    }

                    return Positioned(
                      top: posicaoY,
                      left: 55, 
                      right: 10,
                      height: alturaCalculada,
                      child: LongPressDraggable<Map<String, dynamic>>(
                        data: evento,
                        // Visual do cartão enquanto flutua acompanhando o dedo
                        feedback: Material(
                          color: Colors.transparent,
                          child: Opacity(
                            opacity: 0.9, // Pouco mais forte que antes para não perder a cor real
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 65,
                              height: alturaCalculada,
                              child: Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
                                  ]
                                ),
                                child: _construirCartaoEvento(evento, alturaCalculada)
                              ),
                            ),
                          ),
                        ),
                        // Visual fantasma do cartão original no fundo
                        childWhenDragging: Opacity(
                          opacity: 0.2,
                          child: _construirCartaoEvento(evento, alturaCalculada),
                        ),
                        // Cartão fixado normal
                        child: _construirCartaoEvento(evento, alturaCalculada),
                      ),
                    );
                  }),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}