import 'dart:math';

import 'package:anasislam/helper/http_client.dart';
import 'package:anasislam/helper/layout_helper.dart';
import 'package:anasislam/helper/login_auth.dart';
import 'package:anasislam/helper/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuestionList extends StatefulWidget {
  final String title;
  final bool answered;
  final bool deleted;
  final String type; // default is question otherwise fatawa
  final String query_date_name; // default is question otherwise fatawa
  QuestionList(
      {Key key,
      this.title,
      this.answered,
      this.deleted,
      this.type,
      this.query_date_name})
      : super(key: key);

  @override
  _QuestionListState createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  Firestore _firestore = Firestore.instance;
  List<dynamic> _questions = []; // List<DocumentSnapshot>
  bool _userLoggedIn = false;
  bool _loadingQuestions = true;
  bool _gettingMoreQuestions = false;
  bool _moreQuestionsAvailable = true;
  int perPage = 20;
  Map<String, dynamic> _lastDocument; //DocumentSnapshot
  ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  MyHttpClient httpClient = new MyHttpClient();
  final Auth auth = new Auth();

  List<TextEditingController> _questionController = new List();
  List<TextEditingController> _answerController = new List();

  classQuery() {
    return '?answered=' +
        widget.answered.toString() +
        '&deleted=' +
        widget.deleted.toString() +
        '&type=' +
        widget.type +
        '&query_date_name=' +
        widget.query_date_name;
  }

  _getQuestions() async {
//    Query q = _firestore.collection('QUESTIONS').orderBy("date_created").limit(35);
    _questions = await httpClient.getQuestions(classQuery() + "&limit=35");
    setState(() {
      _loadingQuestions = true;
    });
//    QuerySnapshot querySnapshot = await q.getDocuments();
//    _questions = querySnapshot.documents;
//    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    if (_questions.length > 0) {
      _lastDocument = _questions[_questions.length - 1];
    }
    setState(() {
      _loadingQuestions = false;
    });
  }

  _getMoreQuestions() async {
    print("Ruby is Getting More Data");
    if (_moreQuestionsAvailable == false || _gettingMoreQuestions == true) {
      return;
    }
    setState(() {
      _gettingMoreQuestions = true;
    });
    var allQuestions = await httpClient.getQuestions(classQuery() +
        "&limit=$perPage&last_document=" +
        _lastDocument['document_id']);
//    Query q = _firestore
//        .collection("QUESTIONS")
//        .orderBy("date_created")
//        .startAfter([_lastDocument.data['date_created']]).limit(perPage);
//    QuerySnapshot querySnapshot = await q.getDocuments();
//    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
//    _questions.addAll(querySnapshot.documents);
    if (allQuestions.length < perPage || allQuestions.isEmpty) {
      _moreQuestionsAvailable = false;
    }
    if (allQuestions.isNotEmpty) {
      _lastDocument = allQuestions[allQuestions.length - 1];
    }
    _questions.addAll(allQuestions);
    setState(() {
      _gettingMoreQuestions = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getQuestions();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if (maxScroll - currentScroll <= delta) {
        _getMoreQuestions();
      }
    });

    auth.getCurrentUser().then((value) {
      if (value != null && value.uid != null) {
        _userLoggedIn = true;
      }
    });
//    List<dynamic> _questions = [];
  }

  @override
  Widget build(BuildContext context) {
    return mainViews(
        scaffoldKey,
        widget.title,
        Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                widget.type == 'fatawa' && _userLoggedIn == true ? _addNewFatawa() : Container()
              ],
            ),
            _implementListView()
          ],
        ));
  }

  Widget _implementListView() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: _loadingQuestions
                ? loading()
                : _questions.length == 0
                    ? Center(child: Text('no_questions_to_show'.tr()))
                    : Container(
                        child: Expanded(
                          child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _questions.length,
                              itemBuilder: (BuildContext ctx, int index) {
                                _questionController
                                    .add(new TextEditingController());
                                _answerController
                                    .add(new TextEditingController());

                                if(widget.type =='fatawa'){
                                  return _fatawaView(index);
                                }else{
                                  if (_userLoggedIn) {
                                    return _adminView(index);
                                  }
                                  return _userView(index);
                                }
                              }),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _addNewFatawa() {
    return Container(
      width: 250,
      child: FlatButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'add_new_fatawa'.tr(),
              style: arabicTxtStyle(),
            ),
            Icon(
              Icons.add,
              color: Colors.green,
            )
          ],
        ),
        onPressed: () {
          _addNewFatawaDialog();
        },
      ),
    );
  }

  Widget _fatawaView(index) {
    final currentQuestion = _questions[index];
    print(currentQuestion);
    return ExpansionTile(
      key: Key(currentQuestion["question"] +
          currentQuestion["date_created"].toString()),
      title: Text((safeSubstring(currentQuestion["question"], 0, 55)),
          maxLines: 1,
          style: arabicTxtStyle(),
          overflow: TextOverflow.ellipsis),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(currentQuestion["question"],
                      style: arabicTxtStyle(paramSize: 17))),
            ),
          ],
        ),
        SizedBox(height: 10),
        _bottomOptions(index, currentQuestion)
      ],
    );
  }

  _addNewFatawaDialog() {
    final bodyTxt = TextEditingController();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
                width: 400.0,
                child: SingleChildScrollView(
                  child: Column(
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
                              "add_new_fatawa".tr(),
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
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: TextField(
                          controller: bodyTxt,
                          decoration: InputDecoration(
                            hintText: "fatawa".tr() + " ....",
                            border: InputBorder.none,
                          ),
                          maxLines: 8,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            decoration: kBoxDecorationStyle,
                            height: 60.0,
                            child: Container(
                              child: FlatButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'save'.tr(),
                                      style: arabicTxtStyle(
                                          paramColour: Colors.white,
                                          paramSize: 25),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  if (bodyTxt.text.length > 10) {
                                    httpClient
                                        .saveQuestions(bodyTxt.text,
                                            type: 'fatawa', answered: true)
                                        .then((response) {
                                      if (response['status'] == 'SUCCESS') {
                                        _questions.insert(0, response['data']);
                                        bodyTxt.text = "";
                                        scaffoldKey.currentState.showSnackBar(
                                            SnackBar(
                                                content: Text("saved".tr())));
                                        Navigator.pop(context);
                                        setState(() {});
                                      }
                                    });
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                  }
                                },
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )),
          );
        });
  }

  Widget _userView(index) {
    final currentQuestion = _questions[index];
    print(currentQuestion);
    return ExpansionTile(
      key: Key(currentQuestion["question"] +
          currentQuestion["date_created"].toString()),
      title: Text((safeSubstring(currentQuestion["question"], 0, 55)),
          maxLines: 1,
          style: arabicTxtStyle(),
          overflow: TextOverflow.ellipsis),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(currentQuestion["question"],
                      style: arabicTxtStyle(paramSize: 17))),
            ),
          ],
        ),
        Divider(
          height: isLargeScreen(context) ? 20 : 10,
          thickness: 1,
          color: Colors.black.withOpacity(0.3),
          indent: 32,
          endIndent: 32,
        ),
        currentQuestion['answered'] == true
            ? Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(currentQuestion["answer"] != null ? currentQuestion["answer"] : '' ,
                            style: arabicTxtStyle(
                                paramSize: 17, paramColour: Colors.green))),
                  ),
                ],
              )
            : Container(
                child:
                    Text('this_question_not_answered', style: arabicTxtStyle())
                        .tr()),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _adminView(index) {
    final currentQuestion = _questions[index];
    return Dismissible(
        key: Key(safeSubstring(currentQuestion["question"], 0, 8) +
            currentQuestion["date_created"].toString()),
//                      key: ValueKey(index),
        background: Container(
          color: Colors.red[300],
          padding: EdgeInsets.symmetric(horizontal: 50),
          alignment: AlignmentDirectional.centerStart,
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        secondaryBackground: Container(
          color: Colors.green[400],
          padding: EdgeInsets.symmetric(horizontal: 20),
          alignment: AlignmentDirectional.centerEnd,
          child: Icon(
            Icons.done,
            color: Colors.white,
          ),
        ),
        onDismissed: (direction) {
          return handleDismiss(direction, index);
        },
        child: _createEntry(index));
  }

  Widget _createEntry(index) {
    final currentQuestion = _questions[index];
//    setState(() {
//
//    });
    if (_questionController[index].text == "") {
      _questionController[index].text = currentQuestion["question"];
    }

    if (_answerController[index].text == "") {
      _answerController[index].text =
          currentQuestion["answer"] != null ? currentQuestion["answer"] : "";
    }
    return ExpansionTile(
      key: Key(currentQuestion["question"] +
          currentQuestion["date_created"].toString()),
      title: Text((safeSubstring(currentQuestion["question"], 0, 55)),
          maxLines: 1,
          style: arabicTxtStyle(),
          overflow: TextOverflow.ellipsis),
      children: <Widget>[
        Column(
          children: <Widget>[
            ExpansionTile(
                key: Key(currentQuestion["date_created"]),
                title: Text(currentQuestion["question"],
                    style: arabicTxtStyle(paramSize: 17)),
                children: <Widget>[
                  _inputText(_questionController[index], maxLine: 3),
                ]),
            Divider(
              height: isLargeScreen(context) ? 20 : 10,
              thickness: 1,
              color: Colors.black.withOpacity(0.3),
              indent: 32,
              endIndent: 32,
            ),
            _inputText(_answerController[index],
                hintText: "your_answer..".tr()),
            _bottomOptions(index, currentQuestion),
          ],
        )
      ],
    );
  }

  Widget _bottomOptions(index, currentQuestion) {
    return _userLoggedIn == true
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Text(
                  formatDate(DateTime.parse(
                      currentQuestion["date_created"].toString())),
//                                  formatDate(DateTime.parse(currentQuestion["date_created"].toDate().toString())), // old line from firebase use
                  style: arabicTxtStyle(paramSize: 15),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.content_copy,
                  color: Colors.green,
                ),
                tooltip: 'copy'.tr(),
                onPressed: () {
                  setState(() {
                    Clipboard.setData(
                        ClipboardData(text: currentQuestion["question"]));
                    scaffoldKey.currentState
                        .showSnackBar(SnackBar(content: Text("copied".tr())));
                  });
                },
              ),
              widget.type == 'question'
              ? IconButton(
                icon: Icon(
                  Icons.done,
                  color: Colors.green,
                ),
                tooltip: 'answer'.tr(),
                onPressed: () {
                  handleDismiss(DismissDirection.endToStart, index);
                },
              )
              : Container(),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                tooltip: 'delete'.tr(),
                onPressed: () {
                  handleDismiss(DismissDirection.startToEnd, index);
                },
              ),
            ],
          )
        : Container();
  }

  Widget _inputText(_controller, {maxLine: 7, hintText: ''}) {
    return Container(
      padding: EdgeInsets.all(6),
      child: TextField(
        key: PageStorageKey(Random),
        controller: _controller,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: UtilColours.SAVE_BUTTON, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: Colors.blue)),
        ),
        maxLines: maxLine,
      ),
    );
  }

  handleDismiss(DismissDirection direction, int index) {
    final currentQuestion = _questions[index];
    closeQuestion() {
      if (direction == DismissDirection.startToEnd) {
        httpClient.updateQuestion(currentQuestion['document_id'], {
          "deleted": true,
          "answered": false,
          "date_deleted": DateTime.now().toString()
        }).then((value) {
          scaffoldKey.currentState.showSnackBar(
              SnackBar(
                  content: Text("deleted".tr())));
        });
      } else if (direction == DismissDirection.endToStart) {
        httpClient.updateQuestion(currentQuestion['document_id'], {
          "answered": true,
          "deleted": false,
          "type": 'question',
          "date_answered": DateTime.now().toString(),
          "question": _questionController[index].text,
          "answer": _answerController[index].text,
        }).then((value) {
          scaffoldKey.currentState.showSnackBar(
              SnackBar(
                  content: Text("answered".tr())));
        });
      }
      setState(() {
        _questions.removeAt(index);
        _questionController.removeAt(index);
        _answerController.removeAt(index);
      });
      // deleteFirebaseDocument(currentQuestion.documentID);  //old line from firebase
    }
    closeQuestion();
  }

  final kBoxDecorationStyle = BoxDecoration(
    color: UtilColours.SAVE_BUTTON,
    borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  );
}
