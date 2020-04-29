import 'package:cloud_firestore/cloud_firestore.dart';
const QUESTION_AND_ANSWER = 'QUESTIONS';

Future<void> addQuestion(question) async {
  final databaseReference = Firestore.instance;
  DateTime now = DateTime.now();
  DocumentReference ref = await databaseReference.collection(QUESTION_AND_ANSWER)
      .add({
    'question': question,
    'date_created': now,
  });
  print(ref.documentID);
}

deleteFirebaseDocument(documentID) async{
  final databaseReference = Firestore.instance;
  databaseReference.collection('QUESTIONS').document(documentID).delete();
//  await Firestore.instance.runTransaction((Transaction myTransaction) async {
//    print(reference);
//    await myTransaction.delete(reference);
//
//  });
}
