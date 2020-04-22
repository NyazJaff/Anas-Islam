import 'package:flutter/material.dart';
import 'package:anasislam/helper/util.dart';

TextStyle arabicTxtStyle({paramColour: UtilColours.APP_BAR, double paramSize: 20.0, paramBold: false}){

   return TextStyle(
      fontSize: paramSize,
      color: paramColour,
      fontStyle: FontStyle.normal,
       fontWeight: paramBold ? FontWeight.bold : FontWeight.normal,
  );
}

Widget appBgImage(){
  return Container(
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(-0.9, -0.8),
        radius: 0.15,
        colors: <Color>[
          const Color(0xFFEEEEEE),
          UtilColours.APP_BACKGROUND,
        ],
        stops: <double>[0.9, 1.0],
      ),
//      image: DecorationImage(
//        image: AssetImage("assets/brand/bg_tran.png"),
//        fit: BoxFit.cover,
//      ),
    ),
  );
}