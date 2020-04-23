import 'package:anasislam/sidebar/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'layout_helper.dart';

String safeSubstring(text, start, end){
  int length = text.length;
  return text.substring(start, length >= end ? end : length);
}

double utilWinHeightSize(BuildContext context){
  return MediaQuery.of(context).size.height;
}

bool isLargeScreen(BuildContext context){
  return utilWinHeightSize(context) > 530;
}

appBar(BuildContext context, title){
  return  AppBar(
    leading: new IconButton(
      icon: new Icon(Icons.arrow_back, color: UtilColours.APP_BAR_NAV_BUTTON),
      onPressed: () => Navigator.of(context).pop(),
    ),
    backgroundColor: UtilColours.APP_BAR,
//          backgroundColor: Color(0x44000000),
    elevation: 0,
    title: Text(title,  style: TextStyle(
        color: UtilColours.APP_BAR_NAV_BUTTON,
        fontFamily: "Tajawal"
    )),
  );
}

mainViews(scaffoldKey, viewBody){
  return Scaffold(
    body: Stack(children: <Widget>[
      appBgImage(),
      Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: CustomDrawer(),
        appBar: AppBar(
          iconTheme: new IconThemeData(color: UtilColours.APP_BAR),
          // The icon and color for drawer, by default is white
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Builder(
            builder: (BuildContext context) {
              return viewBody;
            }),
      ),
    ]),
  );
}

launchURL(url) async {
//    const url = 'https://flutter.dev';
  if (await canLaunch(url)) {
    await launch(url,  forceSafariVC: false);
  } else {
    throw 'Could not launch $url';
  }
}

bool utilIsAndroid(context){
  bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
  return isAndroid;
}

showToast(context, message){
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: 2),
  ));
}


class UtilColours {
  static const Color PRIMARY_BROWN = Color(0xffc6ac6e);
  static const Color SAVE_BUTTON = Color(0xff00bfa5);

  static const Color APP_BAR = Color(0xff38606A);
  static const Color DRAWER = Color(0xff38606A);
  static const Color APP_BAR_NAV_BUTTON = Color(0xffE1D7D5);
  static const Color APP_BACKGROUND = Color(0xffE1D7D5);
}