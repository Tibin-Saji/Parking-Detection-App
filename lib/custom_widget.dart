import 'package:flutter/material.dart';

class TextCustom extends StatelessWidget {
  // const TextSmall({Key? key}) : super(key: key);

  String text;
  TextAlign align;
  Color color;
  double size;
  FontWeight weight;

  TextCustom(this.text,
      {Key? key,
      this.align = TextAlign.left,
      this.color = Colors.black54,
      this.size = 24,
      this.weight = FontWeight.w500})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: align,
        style: TextStyle(
          fontWeight: weight,
          fontSize: size,
          color: color,
          fontFamily: 'Exo2',
        ));
  }
}

class ElevatedButtonCustom extends StatelessWidget {
  ElevatedButtonCustom(
      {Key? key,
      required this.onPressed,
      required this.child,
      this.color = Colors.black45,
      this.nullColor = Colors.grey})
      : super(key: key);
  Function()? onPressed;
  double borderRadius = 0;
  Widget child;
  Color nullColor;
  Color color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: color,
          onSurface: nullColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: child);
  }
}
