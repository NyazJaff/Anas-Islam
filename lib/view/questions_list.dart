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
  List<DocumentSnapshot> _questions = [];
  bool _loadingQuestions = true;
  bool _gettingMoreQuestions = false;
  bool _moreQuestionsAvailable = true;
  int perPage = 20;
  DocumentSnapshot _lastDocument;
  ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  _getQuestions() async {
    Query q =
    _firestore.collection('QUESTIONS').orderBy("date_created").limit(50);

    setState(() {
      _loadingQuestions = true;
    });

    QuerySnapshot querySnapshot = await q.getDocuments();
    _questions = querySnapshot.documents;
    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];

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
    Query q = _firestore
        .collection("QUESTIONS")
        .orderBy("date_created")
        .startAfter([_lastDocument.data['date_created']]).limit(perPage);

    QuerySnapshot querySnapshot = await q.getDocuments();
    if (querySnapshot.documents.length < perPage) {
      _moreQuestionsAvailable = false;
    }
    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    _questions.addAll(querySnapshot.documents);

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
      Container(
        child: _questions.length == 0
            ? Center(
          child: Text('No questions to show'),
        )
            : ListView.builder(
            controller: _scrollController,
            itemCount: _questions.length,
            itemBuilder: (BuildContext ctx, int index) {
              final swipedEmail = _questions[index];
              return Dismissible(
                  key: Key(_questions[index].data["question"] + _questions[index].data["date_created"].toString()),
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
                    return handleDismiss(direction, index, swipedEmail);
                  },
                  child: ExpansionTile(
                    key: Key(_questions[index].data["question"] + _questions[index].data["date_created"].toString()),
                    title: Text(
                        _questions[index].data["question"],
                        style: arabicTxtStyle(),
                        overflow: TextOverflow.ellipsis),
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 9, right: 9),
                            child: Text(
                                _questions[index].data["question"],
                                style: arabicTxtStyle(paramSize: 17)) ,
                          ),
                          Row (
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.content_copy),
                                tooltip: 'copy'.tr(),
                                onPressed: () {
                                  setState(() {
                                    Clipboard.setData(ClipboardData(text: _questions[index].data["question"]));
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
//                    ListTile(
//                      title: Text(_questions[index].data["question"]),
//                    ),
              );
            }),
      ),
    );
  }

  handleDismiss(DismissDirection direction, int index,swipedEmail) {

    print(swipedEmail);
    _questions.removeAt(index);
    setState(() {});
    // Remove the dismissed item from the list

//    setState(() {});
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
        duration: Duration(seconds: 4),
        action: SnackBarAction(
            label: "Undo",
            textColor: Colors.yellow,
            onPressed: () {
              setState(() => _questions.insert(index, swipedEmail));
//                  setState(() {});
            }),
      ),
    )
        .closed
        .then((reason) {
      if (reason != SnackBarClosedReason.action) {
        // Make API call to backend to update status
      }
    });
  }
}
