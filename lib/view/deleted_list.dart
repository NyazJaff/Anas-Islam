import 'package:anasislam/helper/http_client.dart';
import 'package:anasislam/helper/layout_helper.dart';
import 'package:anasislam/helper/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class DeletedQuestionsList extends StatefulWidget {
  final String title;
  DeletedQuestionsList({Key key, this.title}) : super(key: key);

  @override
  _DeletedQuestionsListState createState() => _DeletedQuestionsListState();
}

class _DeletedQuestionsListState extends State<DeletedQuestionsList> {
  List<dynamic> _questions = []; // List<DocumentSnapshot>
  bool _loadingQuestions = true;
  ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  MyHttpClient httpClient = new MyHttpClient();

  _getDeletedQuestions() async {
    setState(() {_loadingQuestions = true;});
    _questions = await httpClient.getDeletedQuestions();
    setState(() {_loadingQuestions = false;});
  }

  @override
  void initState() {
    super.initState();
    _getDeletedQuestions();
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
              return _createEntry(index);
            }),
      ),
    );
  }

  Widget _createEntry(index){
    final currentQuestion = _questions[index];
    return ExpansionTile(
      key: Key(currentQuestion["question"] + currentQuestion["date_created"].toString()),
      title: Text(
          (safeSubstring(currentQuestion["question"] ,0, 55)),
          maxLines: 1,
          style: arabicTxtStyle(paramColour: Colors.redAccent),
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
        Column(
          children: <Widget>[
            Divider(
              height: isLargeScreen(context) ? 20 : 10,
              thickness: 1,
              color: Colors.black.withOpacity(0.3),
              indent: 32,
              endIndent: 32,
            ),
            _bottomQuestionOptions(index, currentQuestion),
          ],
        )
      ],
    );
  }

  Widget _bottomQuestionOptions(index, currentQuestion){
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
      ],
    );
  }


}
