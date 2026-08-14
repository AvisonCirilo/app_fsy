import 'package:flutter/material.dart';

class MeuBotao extends StatelessWidget {
  final String texto;
  final void Function()? onTap;
  final Color? corFundo;
  final Color? corTexto;

  const MeuBotao({
    super.key,
    required this.texto,
    required this.onTap,
    this.corFundo,
    this.corTexto,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              corFundo ??
              const Color.fromARGB(255, 160, 240, 108), // Amarelo por padrão
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            texto,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: corTexto ?? Colors.black, // Texto preto por padrão
            ),
          ),
        ),
      ),
    );
  }
}
