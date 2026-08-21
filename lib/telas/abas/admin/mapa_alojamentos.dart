import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapaAlojamentos extends StatefulWidget {
  const MapaAlojamentos({super.key});

  @override
  State<MapaAlojamentos> createState() => _MapaAlojamentosState();
}

class _MapaAlojamentosState extends State<MapaAlojamentos> {

  // Painel rápido para a logística colocar o jovem num quarto diretamente por esta tela
  void _alocarJovem(String jovemId, String nomeJovem) {
    TextEditingController quartoCtrl = TextEditingController();
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24, 
            left: 24, right: 24, top: 24
          ),
          decoration: BoxDecoration(
            color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Icon(Icons.hotel, size: 30, color: Colors.indigo),
              const SizedBox(height: 10),
              Text("Alocar $nomeJovem", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              TextField(
                controller: quartoCtrl,
                autofocus: true,
                style: TextStyle(color: isEscuro ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: "Nome/Número do Quarto (Ex: Bloco A - 101)",
                  filled: true, fillColor: isEscuro ? Colors.black26 : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (quartoCtrl.text.trim().isEmpty) return;
                    Navigator.pop(context);
                    
                    try {
                      await FirebaseFirestore.instance.collection('jovens').doc(jovemId).update({
                        'quarto': quartoCtrl.text.trim()
                      });
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jovem alocado com sucesso!"), backgroundColor: Colors.green));
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao alocar: $e"), backgroundColor: Colors.redAccent));
                    }
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Confirmar Quarto", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEscuro = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2, // Teremos 2 abas: Quartos Fechados e Pendentes
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mapa de Alojamentos"),
          bottom: const TabBar(
            indicatorColor: Colors.indigo,
            labelColor: Colors.indigo,
            tabs: [
              Tab(icon: Icon(Icons.meeting_room), text: "Quartos"),
              Tab(icon: Icon(Icons.person_off), text: "Sem Quarto"),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('jovens').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.indigo));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Nenhum jovem cadastrado ainda."));
            }

            // O nosso algoritmo de triagem logística
            Map<String, List<DocumentSnapshot>> quartos = {};
            List<DocumentSnapshot> semQuarto = [];

            for (var doc in snapshot.data!.docs) {
              String quarto = (doc.data() as Map).containsKey('quarto') ? doc['quarto'].toString().trim() : "";
              
              if (quarto.isEmpty || quarto.toLowerCase() == "a definir") {
                semQuarto.add(doc);
              } else {
                if (!quartos.containsKey(quarto)) {
                  quartos[quarto] = [];
                }
                quartos[quarto]!.add(doc);
              }
            }

            // Ordena os quartos por ordem alfabética
            List<String> nomesQuartos = quartos.keys.toList()..sort();

            return TabBarView(
              children: [
                // =====================================
                // ABA 1: QUARTOS ORGANIZADOS
                // =====================================
                nomesQuartos.isEmpty
                  ? const Center(child: Text("Nenhum quarto montado ainda."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: nomesQuartos.length,
                      itemBuilder: (context, index) {
                        String nomeQuarto = nomesQuartos[index];
                        List<DocumentSnapshot> jovensNoQuarto = quartos[nomeQuarto]!;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isEscuro ? Colors.white12 : Colors.grey.shade200)),
                          child: ExpansionTile(
                            leading: CircleAvatar(backgroundColor: Colors.indigo.withValues(alpha: 0.15), child: const Icon(Icons.hotel, color: Colors.indigo)),
                            title: Text(nomeQuarto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text("${jovensNoQuarto.length} ocupante(s)", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            children: jovensNoQuarto.map((jovem) {
                              bool temAlerta = jovem['saude'] != "Nenhuma" || jovem['medicamento'].toString().isNotEmpty;
                              
                              return ListTile(
                                leading: const Icon(Icons.person, color: Colors.grey),
                                title: Text(jovem['nome'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                subtitle: Text("Cia: ${jovem['companhia']}", style: const TextStyle(fontSize: 12)),
                                trailing: temAlerta 
                                    ? Tooltip(message: "Alerta Médico", child: const Icon(Icons.health_and_safety, color: Colors.redAccent, size: 20))
                                    : IconButton(
                                        icon: const Icon(Icons.edit_location_alt, size: 20, color: Colors.grey),
                                        onPressed: () => _alocarJovem(jovem.id, jovem['nome']),
                                      ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),

                // =====================================
                // ABA 2: JOVENS SEM QUARTO
                // =====================================
                semQuarto.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, size: 60, color: Colors.green),
                          const SizedBox(height: 10),
                          Text("Todos os jovens estão alojados!", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: semQuarto.length,
                      itemBuilder: (context, index) {
                        final jovem = semQuarto[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3))),
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.redAccent.withValues(alpha: 0.15), child: Text(jovem['nome'][0], style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                            title: Text(jovem['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${jovem['idade']} anos • ${jovem['companhia']}"),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              onPressed: () => _alocarJovem(jovem.id, jovem['nome']),
                              child: const Text("Alocar", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      },
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}