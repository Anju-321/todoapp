import 'package:flutter/material.dart';

const primaryClr = Color(0xFF3A416F),
    strokeClr = Color(0xFFC2C2C2),
    whiteClr = Color(0xFFFFFFFF),
    greyBgClr = Color(0xFFF1F1F1),
    redClr = Color(0xFFC01111),
     cardClr= Color(0XFFF4F4F4),
    greenClr = Color(0xFF27803B),
    inputHintClr = Color(0xFF605D5D);


    final Gradient gradientFontcolor = getGradient();
 Gradient getGradient() {
  return const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF3A416F),
      Color(0xFF141727),
    ],
  );
}
var drawerlinearGradient = const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              
                colors: [
               
                Color(0xFFA8B8D8),
                 Color(0xFF576782),
              ]);
     const         appGradientClr=LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3A416F),
                
                Color(0xFF141727),
              ],
            );