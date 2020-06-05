import 'package:anasislam/loading/flip_loader.dart';
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

Widget loading(){
  return Padding (
    padding: EdgeInsets.all(20.0),
    child: ColorLoader4 (
      dotOneColor:  Colors.red,
      dotTwoColor:  Colors.lightGreen,
      dotThreeColor:  Colors.blue,
      duration:  Duration(seconds: 2),
    ),
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