import 'package:anasislam/helper/http_client.dart';
import 'package:anasislam/helper/layout_helper.dart';
import 'package:anasislam/helper/login_auth.dart';
import 'package:anasislam/helper/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class QuestionList extends StatefulWidget {
  final String title;
  final bool answered;
  final bool deleted;
  final String type; // default is question otherwise fatawa
  final String query_date_name; // default is question otherwise fatawa
  QuestionList({Key key, this.title, this.answered, this.deleted, this.type, this.query_date_name}) : super(key: key);

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

  classQuery(){
    return
        '?answered='        + widget.answered.toString() +
        '&deleted='         + widget.deleted.toString() +
        '&type='            + widget.type +
        '&query_date_name=' + widget.query_date_name;
  }

  _getQuestions() async {
//    Query q = _firestore.collection('QUESTIONS').orderBy("date_created").limit(35);
    _questions = await httpClient.getQuestions(classQuery() + "&limit=35");
    setState(() {_loadingQuestions = true;});
//    QuerySnapshot querySnapshot = await q.getDocuments();
//    _questions = querySnapshot.documents;
//    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    if(_questions.length > 0) {
      _lastDocument = _questions[_questions.length - 1];
    }
    setState(() {_loadingQuestions = false;});
  }

  _getMoreQuestions() async {
    print("Ruby is Getting More Data");
    if (_moreQuestionsAvailable == false || _gettingMoreQuestions == true) {
      return;
    }
    setState(() {_gettingMoreQuestions = true;});
    var allQuestions = await httpClient.getQuestions(classQuery() + "&limit=$perPage&last_document="+_lastDocument['document_id']);
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
    if(allQuestions.isNotEmpty){
      _lastDocument = allQuestions[allQuestions.length - 1];
    }
    _questions.addAll(allQuestions);
    setState(() {_gettingMoreQuestions = false;});
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
      if(value != null && value.uid != null){
        _userLoggedIn = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return mainViews(
      scaffoldKey,
        widget.title,
      Container(
        child: _loadingQuestions ?
        loading() :
        _questions.length == 0
            ? Center(child: Text('no_questions_to_show'.tr()))
            : ListView.builder(
            controller: _scrollController,
            itemCount: _questions.length,
            itemBuilder: (BuildContext ctx, int index) {
//              final currentQuestion = _questions[index].data;  // old line from firebase use
              if(!_userLoggedIn){
                return _adminView(index);
              }
              return _userView(index);
            }),
      ),
    );
  }

  Widget _userView(index){
    final currentQuestion = _questions[index];
    print(currentQuestion);
    return ExpansionTile(
      key: Key(currentQuestion["question"] + currentQuestion["date_created"].toString()),
      title: Text(
          (safeSubstring(currentQuestion["question"] ,0, 55)),
          maxLines: 1,
          style: arabicTxtStyle(),
          overflow: TextOverflow.ellipsis),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                      currentQuestion["question"],
                      style: arabicTxtStyle(paramSize: 17))
              ),
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
                  child: Text(
                      currentQuestion["answer"],
                      style: arabicTxtStyle(paramSize: 17, paramColour: Colors.green))
              ),
            ),
          ],
        )
            : Container (child: Text('this_question_not_answered', style: arabicTxtStyle()).tr()),
        SizedBox(
          height: 10
        ),
      ],
    );
  }

  Widget _adminView(index){
    final currentQuestion = _questions[index];
    TextEditingController _questionController = new TextEditingController();
    TextEditingController _answerController = new TextEditingController();
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
          return handleDismiss(direction, index, _questionController, _answerController);
        },
        child: _createEntry(index, _questionController, _answerController)
    );
  }

  Widget _createEntry(index, _questionController, _answerController){
    final currentQuestion = _questions[index];
    _questionController.text = currentQuestion["question"];
    _answerController.text = currentQuestion["answer"] != null ? currentQuestion["answer"] : "";
    return ExpansionTile(
      key: Key(currentQuestion["question"] + currentQuestion["date_created"].toString()),
      title: Text(
          (safeSubstring(currentQuestion["question"] ,0, 55)),
          maxLines: 1,
          style: arabicTxtStyle(),
          overflow: TextOverflow.ellipsis),
      children: <Widget>[
        Column(
          children: <Widget>[
            ExpansionTile(
                key: Key(currentQuestion["date_created"]),
                title: Text(
                  currentQuestion["question"],
                  style: arabicTxtStyle(paramSize: 17)),
                children: <Widget>[
                  _inputText(_questionController, maxLine: 3),
                ]
            ),
            Divider(
              height: isLargeScreen(context) ? 20 : 10,
              thickness: 1,
              color: Colors.black.withOpacity(0.3),
              indent: 32,
              endIndent: 32,
            ),
            _inputText(_answerController, hintText: "your_answer..".tr()),
            _bottomQuestionOptions(index, currentQuestion, _questionController, _answerController),
          ],
        )
      ],
    );
  }

  Widget _bottomQuestionOptions(index, currentQuestion, _questionController, _answerController){
    return Row (
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
          icon: Icon(Icons.content_copy, color: Colors.green,),
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
        IconButton(
          icon: Icon(Icons.done, color: Colors.green,),
          tooltip: 'answer'.tr(),
          onPressed: () {
            handleDismiss(DismissDirection.endToStart, index, _questionController, _answerController);
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red,),
          tooltip: 'delete'.tr(),
          onPressed: () {
            handleDismiss(DismissDirection.startToEnd, index, _questionController, _answerController);
          },
        ),
      ],
    );
  }

  Widget _inputText(_controller, {maxLine: 7, hintText: ''}){
    return Container(
      padding: EdgeInsets.all(6),
      child: TextField(
        controller: _controller,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: hintText,
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
        maxLines: maxLine,
      ),
    );
  }

  handleDismiss(DismissDirection direction, int index, _questionController, _answerController) {
    final currentQuestion = _questions[index];
    closeQuestion(){
        print(currentQuestion['document_id']);
        if (direction == DismissDirection.startToEnd) {
          httpClient.updateQuestion(
              currentQuestion['document_id'],
              { "deleted"      : true,
                "answered"     : false,
                "date_deleted" : DateTime.now().toString()
              });
        }else if(direction == DismissDirection.endToStart) {
          httpClient.updateQuestion(
              currentQuestion['document_id'],
              { "answered"      : true,
                "deleted"       : false,
                "type"          : 'question',
                "date_answered" : DateTime.now().toString(),
                "question"      : _questionController.text,
                "answer"        : _answerController.text,
              });
        }
        // deleteFirebaseDocument(currentQuestion.documentID);  //old line from firebase
    }

    _questions[index]['answer'] = _answerController.text;
//    if(widget.answered == false && direction != DismissDirection.startToEnd){
      _questions.removeAt(index);
//    }
    setState(() {});

    String action;
    if (direction == DismissDirection.startToEnd) {
      //deleteItem();
      action = "deleted";
    } else {
      //archiveItem();
      action = "answered";
    }
    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(action.tr()),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
            label: "Undo",
            textColor: Colors.yellow,
            onPressed: () {
              setState(() => _questions.insert(index, currentQuestion));
//                  setState(() {});
            }),
      ),
    ).closed.then((reason) {
      if (reason != SnackBarClosedReason.action) {
        closeQuestion();
      }
    });
  }
}
