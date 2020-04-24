import 'dart:developer';
import 'package:anasislam/helper/layout_helper.dart';
import 'package:anasislam/sidebar/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageView extends StatefulWidget {
  @override
  _LanguageViewState createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text('', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 26),
              margin: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                'choose_language'.tr(),
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            buildSwitchListTileMenuItem(
                context: context,
                title: 'کوردی',
                locale: EasyLocalization.of(context).supportedLocales[3]),
            buildDivider(),
            buildSwitchListTileMenuItem(
                context: context,
                title: 'عربي',
                locale: EasyLocalization.of(context).supportedLocales[1]),
            buildDivider(),
            buildSwitchListTileMenuItem(
                context: context,
                title: 'فارسی',
                locale: EasyLocalization.of(context).supportedLocales[2]),
            buildDivider(),
            buildSwitchListTileMenuItem(
                context: context,
                title: 'English',
                locale: EasyLocalization.of(context).supportedLocales[0]),
            buildDivider(),
          ],
        ),
      ),
    );
  }

  Container buildDivider() => Container(
    margin: EdgeInsets.symmetric(
      horizontal: 24,
    ),
    child: Divider(
      color: Colors.grey,
    ),
  );

  Container buildSwitchListTileMenuItem(
      {BuildContext context, String title, Locale locale}) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
      ),
      child: ListTile(
          dense: true,
          // isThreeLine: true,
          title: Text(
              title,
              style: arabicTxtStyle(paramSize: 18)
          ),
          onTap: () {
            log(locale.toString(), name: toString());
            EasyLocalization.of(context).locale = locale;
            FocusScope.of(context).unfocus();
//            FocusScope.of(context).requestFocus(new FocusNode());
            Navigator.pop(context);
          }),
    );
  }
}

