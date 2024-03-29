import 'package:flutter/material.dart';
import 'package:tripo/utils/size_config.dart';

class Styles {
  static Color primaryColor = const Color(0xFF282828);
  static Color accentColor = const Color(0xFF030C10);
  static Color primaryWithOpacityColor = const Color(0xFF212E3E);
  static Color yellowColor = const Color(0xFFDFE94B);
  static Color greenColor = const Color(0xFF184248);
  static Color darkGreyColor = const Color(0xFF9E9E9E);
  static Color greyColor = const Color(0xFFE6E8E8);
  static Color whiteColor = const Color(0xFFF8F7F3);
  static Color purewhiteColor = const Color(0xFFFFFFFF);
  static Color buttonColor = const Color(0xFF4C66EE);
  static Color blueColor = const Color(0xFF4BACF7);
  static Color whiteBrownColor = const Color(0xFFF1EEE3);
  static Color redColor = const Color.fromARGB(255, 178, 87, 82);
  static TextStyle textStyle =
      TextStyle(fontSize: getProportionateScreenWidth(15));
  static TextStyle titleStyle = TextStyle(
      fontFamily: 'DMSans',
      fontSize: getProportionateScreenWidth(19),
      fontWeight: FontWeight.w500);
}
