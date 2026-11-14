import 'package:flutter/material.dart';

class MeuCampoTexto extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final IconData? icon;
  final TextEditingController? controller; 

  const MeuCampoTexto({
    super.key,
    required this.hintText,
    required this.obscureText,
    this.icon,
    this.controller, 
  });

  @override
  State<MeuCampoTexto> createState() => _MeuCampoTextoState();
}

class _MeuCampoTextoState extends State<MeuCampoTexto> {
  late bool _esconderTexto;

  @override
  void initState() {
    super.initState();
    _esconderTexto = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: widget.controller, 
      obscureText: _esconderTexto,
      // AQUI ESTÁ A CORREÇÃO: Força a letra a ser preta, já que o fundo da caixa é branco!
      style: TextStyle(color: isEscuro ? Colors.white : Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        hintText: widget.hintText,
        // Garante que o texto de dica também apareça direitinho
        hintStyle: TextStyle(color: isEscuro ? Colors.white54 : Colors.black38), 
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: isEscuro ? Colors.white70 : Colors.grey)
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 45, minHeight: 0),
        suffixIcon: widget.obscureText
            ? GestureDetector(
                onTap: () => setState(() => _esconderTexto = !_esconderTexto),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(_esconderTexto ? Icons.visibility_off : Icons.visibility, color: isEscuro ? Colors.white70 : Colors.grey, size: 22),
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: isEscuro ? Colors.white24 : Colors.grey.shade400)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFFFC107))),
        fillColor: isEscuro ? const Color(0xFF1E1E1E) : Colors.white,
        filled: true,
      ),
    );
  }
}
