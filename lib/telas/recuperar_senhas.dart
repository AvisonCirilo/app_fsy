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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
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
                    color: Color.fromARGB(255, 160, 240, 108), //Green
                  ),
                  const SizedBox(height: 30),
                  
                  const Text(
                    'Precisa de Ajuda?',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  const Text(
                    'Para recuperar o seu acesso, entre em contato direto com a administração do FSY via WhatsApp.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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

/*import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/meu_campo_texto.dart';
import '../components/meu_botao.dart';

class TelaRecuperarSenha extends StatelessWidget {
  const TelaRecuperarSenha({super.key});

  Future<void> _abrirWhatsApp(BuildContext context) async {
    // Coloque o número do administrador aqui (Código do País + DDD + Número)
    // Exemplo: 55 (Brasil) 11 (DDD) 999999999 (Número)
    const numeroTelefone = '5591991239472'; 
    
    // A mensagem padrão que já vai aparecer digitada para a pessoa
    const mensagem = 'Olá, sou líder/consultor do FSY e preciso de ajuda para recuperar minha senha de acesso.';
    
    // Monta o link oficial do WhatsApp
    final Uri url = Uri.parse('https://wa.me/qr/US74VYUHN2MQK1{Uri.encodeComponent(mensagem)}');

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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Deixa a barra invisível
        elevation: 0, // Tira a sombra
        foregroundColor: Colors.black, // Cor da setinha de voltar
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SizedBox(
              width:
                  400, // Mantemos o mesmo limitador de tamanho da tela de login
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_reset, // Ícone de redefinir senha
                    size: 80,
                    color: Color.fromARGB(255, 160, 240, 108),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Recuperar Senha',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    'Entre em contato com o admini',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Reaproveitando nosso campo de texto!
                  /*const MeuCampoTexto(
                    hintText: 'E-mail',
                    obscureText: false,
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 25),*/

                  // Reaproveitando nosso botão!
                  MeuBotao(
                    texto: 'ENVIAR LINK',
                    onTap: () {
                      // Por enquanto, apenas volta para a tela de login
                      Navigator.pop(context);

                      // Mostra um aviso rápido na tela
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Link de recuperação enviado para o e-mail!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
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
*/