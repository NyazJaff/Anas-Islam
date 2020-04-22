import 'package:anasislam/helper/firebase_helper.dart';
import 'package:flutter/material.dart';
import 'package:anasislam/helper/util.dart';
import 'package:anasislam/helper/layout_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../sidebar/custom_drawer.dart';

class SendQuestion extends StatefulWidget {
  SendQuestion({Key key}) : super(key: key);

  _SendQuestionState createState() => _SendQuestionState();
}

class _SendQuestionState extends State<SendQuestion> with WidgetsBindingObserver {
  final commentTxt = TextEditingController();
  bool valid = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack (
          children: <Widget>[
            appBgImage(),
          Scaffold(
            backgroundColor: Colors.transparent,
            drawer: CustomDrawer(),
            appBar: new AppBar(
              title: Text('Anas Islam', style: arabicTxtStyle(paramBold: true, paramSize: 30),),
              iconTheme: new IconThemeData(color: UtilColours.APP_BAR), // The icon and color for drawer, by default is white
              actions: <Widget>[
//                FlatButton(
//                  child: Icon(Icons.language),
//                  onPressed: () {
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (_) => LanguageView(), fullscreenDialog: true),
//                    );
//                  },
//                ),
              ],
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
            body: Center (
              child: Container(
                child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: 'get'.tr(), style: arabicTxtStyle(paramSize: 40, paramBold: true)),
                              TextSpan(text: 'in_touch'.tr(), style: arabicTxtStyle(paramSize: 35, paramBold: true)),
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: utilWinHeightSize(context) > 530
                                    ? utilWinHeightSize(context) * 0.1
                                    : utilWinHeightSize(context) * 0.04)),
                        sendQuestionBox(context),
                        Padding(
                            padding: EdgeInsets.only(
                                top: utilWinHeightSize(context) > 530
                                    ? utilWinHeightSize(context) * 0.1
                                    : utilWinHeightSize(context) * 0.04)),
                        socialMediaLinks()
                      ],
                    )
                ),
              ),
            )
          ),
          ]
      ),
    );
  }

  socialMediaLinks() {
    return Container(
      child: Align(
        alignment: FractionalOffset(0, 0.8),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
//           Text(MediaQuery.of(context).size.height.toString()),
              Padding(
                padding: EdgeInsets.all(7.0),
                child: Container(
                    color: Color(0xff3b5998),
                    width: 40.0,
                    height: 40.0,
                    child: IconButton(
                      icon: Icon(FontAwesomeIcons.instagram),
                      iconSize: 25,
                      color: Colors.white.withOpacity(1),
                      onPressed: () {
                        launchURL('https://www.instagram.com/islam_fatawa2018/');
                      },
                    )),
              ),
              Padding(
                padding: EdgeInsets.all(7.0),
                child: Container(
                    color: Colors.white,
                    width: 40.0,
                    height: 40.0,
                    child: IconButton(
                      icon: Icon(FontAwesomeIcons.youtube),
                      iconSize: 25,
                      color: Color(0xffc4302b),
                      onPressed: () {
                        launchURL('https://www.youtube.com/channel/UC-IQ9xThhjALo7QC3JQNX_g');
                      },
                    )),
              ),
              Padding(
                padding: EdgeInsets.all(7.0),
                child: Container(
                    color: Color(0xff0088cc),
                    width: 40.0,
                    height: 40.0,
                    child: IconButton(
                      icon: Icon(FontAwesomeIcons.telegramPlane),
                      iconSize: 25,
                      color: Color(0xffffffff),
                      onPressed: () {
                        launchURL('https://t.me/islam_Fatawa');
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  sendQuestionBox(ctx) {
    return Builder(
        builder: (ctx) =>  Container(
            width: 300.0,
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "write_question_below".tr(),
                            style: arabicTxtStyle(),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 4.0,
                    ),
                    Padding(
                      padding: EdgeInsets.all(1.0),
                      child: TextField(
                        controller: commentTxt,
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: "your_question..".tr(),
                          border: InputBorder.none,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: UtilColours.SAVE_BUTTON, width: 0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(5.0)),
                              borderSide:
                              BorderSide(color: Colors.blue)),
                        ),
                        maxLines: 9,
                      ),
                    ),
                    !valid ?
                    Padding(
                      padding: const EdgeInsets.only(top:5.0, bottom: 5.0),
                      child: Text(
                        'type_your_question_before_pressing_send'.tr(),
//                      textAlign: TextAlign.center,
//                      overflow: TextOverflow.ellipsis, // make text into dot dot
                        style: arabicTxtStyle(paramSize: 15, paramColour: Colors.redAccent),
                      ),
                    ) : Container (),
                    InkWell(
                      child: Container(
                        padding:
                        EdgeInsets.only(top: 10.0, bottom: 10.0),
                        decoration: BoxDecoration(
                          color: UtilColours.SAVE_BUTTON,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0)),
                        ),
                        child: Text(
                          'send'.tr(),
                          style:
                          arabicTxtStyle(paramColour: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onTap: () async {
                        // Validate returns true if the form is valid, or false
                        // otherwise.
                        if(commentTxt.text.length > 10) {
                          addQuestion(commentTxt.text).then((value) {
                            Scaffold.of(ctx).showSnackBar(SnackBar(
                              content: Text(
                                'received_thank_you'.tr(),
                                style: arabicTxtStyle(paramColour: Colors.white),
                              ),
                              duration: Duration(seconds: 2),
                            ));
                            valid = true;
                            commentTxt.text = "";
                          });
                          FocusScope.of(context).requestFocus(new FocusNode());
                        }else{
                          valid = false;
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],


            ))
    );}
}
