import 'dart:io';
import 'dart:convert';
import 'dart:core';
import 'dart:async';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:device_id/device_id.dart';


class MyHttpClient  {
  HttpClient client = new HttpClient();

  Future<Map<String, dynamic>> saveQuestions(question) async{
    return await _makeJsonPost({
      "question"   : question,
      "deleted"    : false,
      "answered"   : false,
      "device_id"  : await DeviceId.getID,
//      "date_added" : DateTime.now().toString()
    });
  }


  Future<Map<String, dynamic>> updateQuestion(documentId, dataParam) async {
    var response = await _makeJsonPut(dataParam, url: documentId);
    if(response['status'] == "SUCCESS")
      return response['data'];
    else{
      return {};
    }
//    return await _makeJsonGet(url: dataParam);
  }


  void wakeup() async{
    _makeJsonGet(url: 'wakeup_server');
  }

  Future<List<dynamic>> getQuestions(dataParam) async {
    var response = await _makeJsonGet(url: dataParam);
    if(response['status'] == "SUCCESS")
      return response['data'];
    else{
      return [];
    }
//    return await _makeJsonGet(url: dataParam);
  }

  Future<Map<String, dynamic>> _makeJsonPut(dataParam, {url: ""}) async{
    var response = await http.put(
        apiUrl() + url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"data": dataParam}));
    return _httpJsonResponse(response);
  }

  Future<Map<String, dynamic>> _makeJsonGet({dataParam: "", url: ""}) async{
    var response = await http.get(
        apiUrl() + url,
        headers: {"Content-Type": "application/json"});
    return _httpJsonResponse(response);
  }

  Future<Map<String, dynamic>> _makeJsonPost(dataParam, {url: ""}) async{
    var response = await http.post(
        apiUrl() + url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"data": dataParam}));
    return _httpJsonResponse(response);
  }

  Map<String, dynamic> _httpJsonResponse(response){
    var jsonResponse = convert.jsonDecode(response.body);
    if(jsonResponse['status'] == 'SUCCESS'){
      print('SUCCESS--------- HTTP API SUCCESS MESSAGE  --------------- START');
      print(jsonResponse['data'] != null ? jsonResponse['data'] : 'NO DATA RETUNED');
      print('SUCCESS--------- HTTP API SUCCESS MESSAGE  --------------- END');
    }else{
      print('ERROR--------- HTTP API ERROR MESSAGE  --------------- START');
      print(jsonResponse['message'] != null ? jsonResponse['message'] : 'NO MESSAGE RETURNED');
      print('ERROR--------- HTTP API ERROR MESSAGE  --------------- END');
    }
    return jsonResponse;
  }

  String apiUrl(){
    if(!kReleaseMode) {
      return 'http://localhost:3000/api/v1/anas_islam/';
    }
    return 'https://anas-islam.herokuapp.com/api/v1/anas_islam/';
  }
}
