import 'package:flutter/material.dart';

extension CustomColors on BuildContext {
  Color get colorBlack => Colors.black;
}

extension TextStyles on BuildContext {
  TextStyle get AppBarStyle =>
      TextStyle(fontSize: 24, color: colorBlack, fontWeight: FontWeight.w800);

  TextStyle get textStyle1 =>
      TextStyle(fontSize: 16, color: colorBlack, fontWeight: FontWeight.bold);

  TextStyle get buttonTextStyle =>
      TextStyle(fontSize: 20, color: colorBlack, fontWeight: FontWeight.w800);

  Color get Color1 => Color(0xFF6A9AB0);
  Color get Color2 => Color(0xFF3A6D8C);
  Color get Color3 => Color(0xFFEAD8B1);
}
