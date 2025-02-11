/*
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String buttonName;
  final Widget? iconName;
  final Function onPressed;

  ActionButton({
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
        elevation: 5,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String buttonName;
  final Widget? iconName;
  final VoidCallback? onPressed; // Ahora acepta funciones asíncronas

  const ActionButton({
    required this.buttonName,
    required this.onPressed,
    this.iconName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Se ejecutará sin problemas incluso si es async
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 5,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconName != null) iconName!,
          if (iconName != null) const SizedBox(width: 10),
          Text(
            buttonName,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
