import 'package:anasislam/loading/flip_loader.dart';
import 'package:anasislam/helper/util.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../helper/layout_helper.dart';
import 'package:anasislam/sidebar/custom_drawer.dart';
import '../helper/login_auth.dart';

class LoginScreen1 extends StatefulWidget {
  @override
  _LoginScreen1State createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen1> {
  final Color logoRound = Color(0xFFEEEEEE);
  final Color foregroundColor = Color(0xFFEEEEEE);
  final AssetImage logo = new AssetImage("assets/brand/logo.png");
  final emailInput = TextEditingController();
  final passwordInput = TextEditingController();
  bool valid = true;
  bool checking = false;
  final Auth auth = new Auth();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
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
            return

              Center(
              child: Container(
                width: 300.0,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: isLargeScreen(context) ? 150.0 : 15, bottom: 50.0),
                        child: Center(
                          child: new Column(
                            children: <Widget>[
                              Container(
                                height: 128.0,
                                width: 128.0,
                                child: new CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: this.logoRound,
                                  radius: 90.0,
                                ),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: UtilColours.APP_BAR,
                                      width: 3.0,
                                    ),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(image: this.logo)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                                style: BorderStyle.solid),
                          ),
                        ),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.only(
                                  top: 10.0, bottom: 10.0, right: 00.0),
                              child: Icon(
                                Icons.alternate_email,
                                color: UtilColours.DRAWER,
                              ),
                            ),
                            new Expanded(
                              child: TextField(
                                controller: emailInput,
//                                style: arabicTxtStyle(),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '.... @ ....',
//                              hintStyle: TextStyle(color: this.foregroundColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                                style: BorderStyle.solid),
                          ),
                        ),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.only(
                                  top: 10.0, bottom: 10.0, right: 00.0),
                              child: Icon(
                                Icons.lock_open,
                                color: UtilColours.DRAWER,
                              ),
                            ),
                            new Expanded(
                              child: TextField(
                                controller: passwordInput,
//                                style: arabicTxtStyle(),
                                obscureText: true,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '*********',
//                              hintStyle: TextStyle(color: this.foregroundColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      !valid
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 5.0, bottom: 5.0),
                              child: Text(
                                'invalid_email_or_password'.tr(),
                                overflow: TextOverflow.ellipsis,
                                style: arabicTxtStyle(
                                    paramSize: 15, paramColour: Colors.redAccent),
                              ),
                            )
                          : Container(),
                      !checking
                          ? InkWell(
                        child: Container(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          decoration: BoxDecoration(
                            color: UtilColours.SAVE_BUTTON,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0)),
                          ),
                          child: Text(
                            'login'.tr(),
                            style: arabicTxtStyle(paramColour: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () async {
                          setState(() {
                            checking = true;
                          });
//                        auth.signIn("anasislam@app.com", "1234567890").then((value) {
                          auth.signIn(emailInput.text, passwordInput.text).then((value) {
                            if (value == 'Success') {
                              FocusScope.of(context).requestFocus(new FocusNode());
                              valid = true;
                              emailInput.text = "";
                              passwordInput.text = "";
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/question_list');
//                            scaffoldKey.currentState
//                                .showSnackBar(new SnackBar(content: new Text('successfully_signed_in'.tr(),)));
                            }else{
                              setState(() {
                                valid = false;
                                checking = false;
                              });
                            }
                          });
                        },
                      )
                          : Padding (
                        padding: EdgeInsets.all(20.0),
                        child: ColorLoader4 (
                          dotOneColor:  Colors.red,
                          dotTwoColor:  Colors.lightGreen,
                          dotThreeColor:  Colors.blue,
                          duration:  Duration(seconds: 2),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }
}
