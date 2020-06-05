import 'package:anasislam/helper/http_client.dart';
import 'package:anasislam/helper/util.dart';
import 'package:zefyr/zefyr.dart';
import 'package:flutter/material.dart';
import 'package:quill_delta/quill_delta.dart';
import 'dart:convert';

//https://zefyr-editor.gitbook.io/docs/quick-start
class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  ZefyrController _controller;
  FocusNode _focusNode;
  MyHttpClient _myHttpClient = new MyHttpClient();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final document = _loadDocument();
    _loadDocument().then((document) {
      setState(() {
        _controller = ZefyrController(document);
      });
    });
    _focusNode = FocusNode();
  }

  void _saveDocument(BuildContext context) async {
    final contents = jsonEncode(_controller.document);
    print(_controller.document.toPlainText());
    var question = await _myHttpClient.saveQuestions(contents);
//    print(question['data']['question']);
    _loadDocument(json: contents);
  }


  Future<NotusDocument> _loadDocument({json: ''}) async {
    print(json);
    if (json != ''){
      return NotusDocument.fromJson(jsonDecode(json));
    }else{
      final Delta delta = Delta()..insert("Zefyr Quick Start\n");
      return NotusDocument.fromDelta(delta);
    }
  }

  @override
  Widget build(BuildContext context) {

    final Widget body = (_controller == null)
        ? Center(child: CircularProgressIndicator())
        : ZefyrScaffold(
          child: ZefyrEditor(
        padding: EdgeInsets.all(16),
        controller: _controller,
        focusNode: _focusNode,
      ),
    );

    return Scaffold(
        appBar: new AppBar(
          title: Text('anas_islam'),
          iconTheme: new IconThemeData(color: UtilColours.APP_BAR), // The icon and color for drawer, by default is white
          actions: <Widget>[
                FlatButton(
                  child: Icon(Icons.language),
                  onPressed: () {
                    _saveDocument(context);
//                    print(_controller.plainTextEditingValue);
                  },
                ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: SafeArea(
          child: Column(
              children: <Widget>[
                Expanded(
                  child: Container (
                    child: body
                  ),
                ),
              ]
          ),
        )
    );
  }
}
