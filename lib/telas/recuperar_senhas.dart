import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Nosso pacote novo!
import '../components/meu_campo_texto.dart';
import '../components/meu_botao.dart';

class TelaRecuperarSenha extends StatelessWidget {
  const TelaRecuperarSenha({super.key});

  // Função que faz a mágica de abrir o WhatsApp
  Future<void> _abrirWhatsApp(BuildContext context) async {
    // Coloque o número do administrador aqui (Código do País + DDD + Número)
    // Exemplo: 55 (Brasil) 11 (DDD) 999999999 (Número)
    const numeroTelefone = '5591991021704'; 
    
    // A mensagem padrão que já vai aparecer digitada para a pessoa
    const mensagem = 'Olá, sou líder/consultor do FSY e preciso de ajuda para recuperar minha senha de acesso.';
    
    // Monta o link oficial do WhatsApp
    final Uri url = Uri.parse('https://wa.me/$numeroTelefone?text=${Uri.encodeComponent(mensagem)}');

    try {
      // Tenta abrir o link no navegador ou no app do WhatsApp
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Não foi possível abrir o WhatsApp');
      }
    } catch (e) {
      // Se der erro (ex: usuário bloqueou abas pop-up), mostra um aviso em vermelho
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao tentar abrir o WhatsApp.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.support_agent, // Mudei para um ícone de suporte
                    size: 80,
                    color: Color.fromARGB(255, 251, 253, 133), //Green
                  ),
                  const SizedBox(height: 30),
                  
                  const Text(
                    'Precisa de Ajuda?',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  Text(
                    'Para recuperar o seu acesso, entre em contato direto com a administração do FSY via WhatsApp.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Opcional: Você pode manter o campo de usuário para a pessoa lembrar qual é, 
                  // ou até removê-lo se quiser que ela vá direto pro WhatsApp.
                  const MeuCampoTexto(
                    hintText: 'Seu Usuário (Opcional)',
                    obscureText: false,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 25),
                  
                  // Botão atualizado!
                  MeuBotao(
                    texto: 'CHAMAR NO WHATSAPP',
                    onTap: () => _abrirWhatsApp(context), // Aciona a nossa função
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

