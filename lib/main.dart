import 'package:anasislam/view/lang_view.dart';
import 'package:anasislam/view/questions_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'view/login_screen.dart';
import 'view/send_question.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main() {
  runApp(EasyLocalization (
    child: new MyApp(),
    supportedLocales: [
      Locale('en', 'UK'),
      Locale('ar', 'SA'),
      Locale('fa', 'PR'),
      Locale('ar', 'KU')
      ],
    path: 'assets/langs',
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var locale = EasyLocalization.of(context).locale;
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: MaterialApp(
          //Route
          initialRoute: '/',
          routes: {
            '/': (context) => SendQuestion(),
            '/languageView': (context) => LanguageView(),
            '/loginscreen1': (context) => LoginScreen1(),
//            '/': (context) => QuestionList(),
            '/question_list': (context) => QuestionList(),
          },

          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            EasyLocalization.of(context).delegate,
            GlobalCupertinoLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate
          ],
          supportedLocales: EasyLocalization.of(context).supportedLocales,
          locale: EasyLocalization.of(context).locale,
//      locale: Locale("ar", "IR"),
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Colors.white,
            primarySwatch: Colors.green,
            textTheme: Theme.of(context).textTheme.apply(
                fontFamily:
                locale.toString() == 'ar_SA' ? 'Tajawal' :
                locale.toString() == 'fa_PR' ? 'Neirizi' :
                locale.toString() == 'ar_KU' ? 'Kurdi' :
                'ProximaNova',
//                fontSizeDelta: locale.toString() == 'fa_PR' ?  0 : 0.0,
            ),
          ),

        )
    );
  }
}