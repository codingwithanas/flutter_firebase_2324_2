
import 'package:flutter/material.dart';

class BombollaMissatge extends StatelessWidget {

  final Color colorBombolla;
  final String missatge;
  final String tiempo;


  const BombollaMissatge({
    super.key,
    required this.colorBombolla,
    required this.missatge,
    required this.tiempo,

  });

 @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorBombolla,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(missatge),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Text(
              tiempo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}