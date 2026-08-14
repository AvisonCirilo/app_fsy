import 'package:flutter/material.dart';

class MeuCampoTexto extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final IconData? icon;

  const MeuCampoTexto({
    super.key,
    required this.hintText,
    required this.obscureText,
    this.icon,
  });

  @override
  State<MeuCampoTexto> createState() => _MeuCampoTextoState();
}

class _MeuCampoTextoState extends State<MeuCampoTexto> {
  // Variável que funcionará como o nosso "interruptor"
  late bool _esconderTexto;

  @override
  void initState() {
    super.initState();
    // O estado inicial será o que passarmos na tela de login (ex: true para a senha)
    _esconderTexto = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _esconderTexto,
      decoration: InputDecoration(
        isDense: true, // Avisa o Flutter para deixar o campo compacto
        // 1. Padronizamos a altura exata da caixa para TODOS os campos
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),

        hintText: widget.hintText,

        // Se houver um ícone do lado esquerdo (prefixo), ele entra aqui
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: Colors.grey)
            : null,

        // 2. A MÁGICA: Removemos a margem obrigatória do sufixo
        suffixIconConstraints: const BoxConstraints(
          minWidth: 45,
          minHeight: 0, // Diz ao Flutter: "Não force uma altura mínima!"
        ),

        // 3. Trocamos o IconButton pelo GestureDetector
        suffixIcon: widget.obscureText
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _esconderTexto = !_esconderTexto;
                  });
                },
                child: Container(
                  color: Colors.transparent, // Aumenta a área de clique de forma invisível
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(
                    _esconderTexto ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 22,
                  ),
                ),
              )
            : null,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFC107)),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  /*@override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _esconderTexto,
      decoration: InputDecoration(
        hintText: widget.hintText, // O texto de dica (ex: Email)
        suffixIcon: widget.icon != null
            ? Icon(widget.icon, color: Colors.grey)
            : null,

        suffix: widget.obscureText
            ? IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _esconderTexto ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _esconderTexto = !_esconderTexto;
                  });
                },
              )
            : null,
        // Borda quando não está selecionado
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        // Borda quando o usuário clica para digitar
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFC107)), // Amarelo
        ),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }*/
}
