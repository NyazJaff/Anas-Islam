import 'package:anasislam/helper/login_auth.dart';
import 'package:anasislam/helper/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../helper/layout_helper.dart';
import 'menu_item.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {

  final Auth auth = new Auth();

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: Theme.of(context).copyWith(
        // Set the transparency here
        canvasColor: UtilColours.APP_BAR, // e.g Colors.blue.withOpacity(0.5)
       ),
      child: Container(
//                width:00,
        child: Drawer(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: UtilColours.DRAWER,
                    child: ListView(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            SizedBox(
                              height: utilWinHeightSize(context) > 530
                                  ? 100
                                  : 0,
                            ),
                            Divider(
                              height: isLargeScreen(context) ? 64 : 30,
                              thickness: 0.5,
                              color: Colors.white.withOpacity(0.3),
                              indent: 32,
                              endIndent: 32,
                            ),
                            MenuItem(
                              icon: Icons.question_answer,
                              title: "send_question".tr(),
                              onTap: () {
//                                        Navigator.of(context).pop();
//                                        Navigator.pushNamed(context, '/home');
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/');
                              },
                            ),
                            FutureBuilder<FirebaseUser> (
                              future: auth.getCurrentUser(),
                              builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
                                if (snapshot.hasData) {
                                  return MenuItem(
                                    icon: Icons.list,
                                    title: "questions".tr(),
                                    onTap: (){
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, '/question_list');
                                    },
                                  );
                                }
                                return Container();
                              },
                            ),
                            Divider(
                              height: isLargeScreen(context) ? 64 : 0,
                              thickness: 0.5,
                              color: Colors.white.withOpacity(0.3),
                              indent: 32,
                              endIndent: 32,
                            ),
                            MenuItem(
                              icon: Icons.language,
                              title: "language".tr(),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/languageView');
                              },
                            ),
                            FutureBuilder<FirebaseUser> (
                              future: auth.getCurrentUser(),
                              builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
                                if (!snapshot.hasData) {
                                  return MenuItem(
                                      icon: Icons.lock_open,
                                      title: "admin".tr(),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        Navigator.pushNamed(context, '/loginscreen1');
                                      },
                                    );
                                }else{
                                  return MenuItem(
                                    icon: Icons.exit_to_app,
                                    title: "logout".tr(),
                                    onTap: (){
                                      Navigator.pop(context);
                                      auth.signOut();
                                      Navigator.pushNamed(context, '/');
                                    },
                                  );
                                }
                              },
                            ),

                          ],
                        ),
                      ],
                    )
                ),
              ),
              Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    color: Colors.amber,
//                    padding: EdgeInsets.all(0),
                    child: ListTile (
                      leading: Icon(Icons.devices_other,color: UtilColours.DRAWER, size: 40.0),
                      subtitle: Text ("Find me on LinkedIn"),
                      title: Text.rich(
                              TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text: 'Developed by', style: arabicTxtStyle(paramSize: 13)),
                                  TextSpan(text: ' Nyaz Jaff', style: arabicTxtStyle(paramSize: 13, paramBold: true)),
                                ],
                              )),
                      onTap: (){
                        Navigator.pop(context);
                        launchURL('https://www.linkedin.com/in/nyazjaff/');
                      },
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
