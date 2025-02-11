import 'package:flutter/material.dart';

class TopActionButton extends StatelessWidget {
  final String buttonName;
  final Widget? iconName;
  final Function onPressed;

  TopActionButton({
    required this.buttonName,
    required this.onPressed,
    this.iconName,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Theme.of(context).primaryColor, // Usar primaryColor del tema
        //const Color.fromARGB(255, 115, 94, 255),
        elevation: 3,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconName != null) iconName!, // Mostrar icono solo si no es nulo
          if (iconName != null)
            const SizedBox(width: 10), // Espacio entre icono y texto
          Text(
            buttonName,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
