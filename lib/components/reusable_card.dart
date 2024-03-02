import 'package:flutter/material.dart';

class GalaxyButton extends StatelessWidget {
  GalaxyButton({required this.colour, this.cardChild, required this.onPress});

  final Color colour;
  final Widget? cardChild;
  final Function() onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(
            color: colour,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.deepPurple.shade700,
                  offset: Offset(4, 4),
                  blurRadius: 15,
                  spreadRadius: 1),
              BoxShadow(
                  color: Colors.deepPurple.shade200,
                  offset: Offset(-4, -4),
                  blurRadius: 15,
                  spreadRadius: 1),
            ],
            gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade200,
                  Colors.deepPurple.shade400,
                ],
                stops: const [
                  0.1,
                  0.9,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: cardChild,
      ),
    );
  }
}
