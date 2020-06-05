import 'dart:async';
import 'package:anasislam/view/deleted_list.dart';
import 'package:anasislam/view/lang_view.dart';
import 'package:anasislam/view/questions_list.dart';
import 'package:anasislam/view/test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'view/login_screen.dart';
import 'view/send_question.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:anasislam/helper/http_client.dart';

void main() {
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  MyHttpClient httpClient = new MyHttpClient();

  httpClient.wakeUpBackendServer();

  runApp(EasyLocalization (
    child: new MyApp(),
    supportedLocales: [
      Locale('en', 'UK'),
      Locale('ar', 'SA'),
      Locale('fa', 'PR'),
      Locale('ar', 'KU')
    ],
    path: 'assets/langs',
    fallbackLocale: Locale('fa', 'PR'),
  ));

//  runZoned(() {
//
//  }, onError: Crashlytics.instance.recordError);
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
          debugShowCheckedModeBanner: false,
          //Route
          initialRoute: '/question_list',
          routes: {
            '/': (context) => SendQuestion(),
            '/languageView': (context) => LanguageView(),
            '/loginscreen1': (context) => LoginScreen1(),
            '/question_list': (context) => QuestionList(title: 'questions'.tr(), answered: false, deleted: false, type: 'question', query_date_name: 'date_created asc'),
            '/answered_list': (context) => QuestionList(title: 'answers'.tr(), answered: true, deleted: false, type: 'question', query_date_name: 'date_answered desc'),
            '/fatawa_list': (context) => QuestionList(title: 'fatawa'.tr(), answered: true, deleted: false, type: 'fatawa', query_date_name: 'date_created desc'),
            '/deleted_list': (context) => DeletedQuestionsList(title: 'Deleted'.tr()),
//            '/pending_questions': (context) => PendingQuestions(),
            '/test': (context) => Test(),
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