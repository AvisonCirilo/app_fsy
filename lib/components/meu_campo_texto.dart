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
    return TextField(
      controller: widget.controller, 
      obscureText: _esconderTexto,
      // AQUI ESTÁ A CORREÇÃO: Força a letra a ser preta, já que o fundo da caixa é branco!
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        hintText: widget.hintText,
        // Garante que o texto de dica também apareça direitinho
        hintStyle: const TextStyle(color: Colors.black38), 
        prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.grey) : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 45, minHeight: 0),
        suffixIcon: widget.obscureText
            ? GestureDetector(
                onTap: () => setState(() => _esconderTexto = !_esconderTexto),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(_esconderTexto ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 22),
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade400)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFFFC107))),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }
}
