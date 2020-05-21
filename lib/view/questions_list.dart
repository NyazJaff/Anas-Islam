import 'package:anasislam/helper/firebase_helper.dart';
import 'package:anasislam/helper/http_client.dart';
import 'package:anasislam/helper/layout_helper.dart';
import 'package:anasislam/helper/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class QuestionList extends StatefulWidget {
  @override
  _QuestionListState createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  Firestore _firestore = Firestore.instance;
  List<dynamic> _questions = []; // List<DocumentSnapshot>
  bool _loadingQuestions = true;
  bool _gettingMoreQuestions = false;
  bool _moreQuestionsAvailable = true;
  int perPage = 20;
  Map<String, dynamic> _lastDocument; //DocumentSnapshot
  ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  MyHttpClient httpClient = new MyHttpClient();

  _getQuestions() async {
//    Query q = _firestore.collection('QUESTIONS').orderBy("date_created").limit(50);
    _questions = await httpClient.getQuestions("?limit=50");
    setState(() {
      _loadingQuestions = true;
    });

//    QuerySnapshot querySnapshot = await q.getDocuments();
//    _questions = querySnapshot.documents;
//    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    if(_questions.length > 0) {
      _lastDocument = _questions[_questions.length - 1];
    }
    setState(() {
      _loadingQuestions = false;
    });
  }

  _getMoreQuestions() async {
    print("Firebase Getting More Data");
    if (_moreQuestionsAvailable == false) {
      return;
    }
    if (_gettingMoreQuestions == true) {
      return;
    }
    _gettingMoreQuestions = true;
    var allQuestions = await httpClient.getQuestions("?limit=50");
//    Query q = _firestore
//        .collection("QUESTIONS")
//        .orderBy("date_created")
//        .startAfter([_lastDocument.data['date_created']]).limit(perPage);
//    QuerySnapshot querySnapshot = await q.getDocuments();
//    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
//    _questions.addAll(querySnapshot.documents);

    if (allQuestions.length < perPage) {
      _moreQuestionsAvailable = false;
    }
    _lastDocument = allQuestions[allQuestions.length - 1];
    _questions.addAll(allQuestions);

    setState(() {});
    _gettingMoreQuestions = false;
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
  }

  @override
  Widget build(BuildContext context) {
    return mainViews(
      scaffoldKey,
      "questions".tr(),
      Container(
        child: _questions.length == 0
            ? Center(child: Text('No questions to show'))
            : ListView.builder(
            controller: _scrollController,
            itemCount: _questions.length,
            itemBuilder: (BuildContext ctx, int index) {
//              final currentQuestion = _questions[index].data;  // old line from firebase use
              final currentQuestion = _questions[index];
              return Dismissible(
                  key: Key(safeSubstring(currentQuestion["question"] ,0, 8) + currentQuestion["date_created"].toString()),
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
                    return handleDismiss(direction, index, _questions[index]);
                  },
                  child: ExpansionTile(
                    key: Key(currentQuestion["question"] + currentQuestion["date_created"].toString()),
                    title: Text(
                        (safeSubstring(currentQuestion["question"] ,0, 55)),
                        maxLines: 1,
                        style: arabicTxtStyle(),
                        overflow: TextOverflow.ellipsis),
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 9, right: 9),
                            child: Text(
                                currentQuestion["question"],
                                style: arabicTxtStyle(paramSize: 17)) ,
                          ),
                          Row (
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 15, right: 15),
                                child: Text(
                                  formatDate(DateTime.parse(currentQuestion["date_created"].toString())),
//                                  formatDate(DateTime.parse(currentQuestion["date_created"].toDate().toString())), // old line from firebase use
                                  style: arabicTxtStyle(paramSize: 15),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.content_copy, color: UtilColours.APP_BAR,),
                                tooltip: 'copy'.tr(),
                                onPressed: () {
                                  setState(() {
                                    Clipboard.setData(ClipboardData(text: currentQuestion["question"]));
                                    scaffoldKey.currentState
                                        .showSnackBar(
                                        SnackBar(
                                            content: Text("copied".tr())));
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      )

                    ],
                  )
              );
            }),
      ),
    );
  }

  handleDismiss(DismissDirection direction, int index,currentQuestion) {
    _questions.removeAt(index);
    setState(() {});
    String action;
    if (direction == DismissDirection.startToEnd) {
      //deleteItem();
      action = "Deleted";
    } else {
      //archiveItem();
      action = "Answered";
    }
    scaffoldKey.currentState
        .showSnackBar(
      SnackBar(
        content: Text("$action. Do you want to undo?"),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
            label: "Undo",
            textColor: Colors.yellow,
            onPressed: () {
              setState(() => _questions.insert(index, currentQuestion));
//                  setState(() {});
            }),
      ),
    )
        .closed
        .then((reason) {
      if (reason != SnackBarClosedReason.action) {
        print(currentQuestion['document_id']);
        if (direction == DismissDirection.startToEnd) {
          httpClient.updateQuestion(currentQuestion['document_id'], {"deleted": true});
        } else {
          httpClient.updateQuestion(currentQuestion['document_id'], {"answered": true});
        }
        // deleteFirebaseDocument(currentQuestion.documentID);  //old line from firebase
      }
    });
  }
}
