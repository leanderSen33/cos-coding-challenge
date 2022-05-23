import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as devtools show log;

import 'package:cosapp/models/user_preferences.dart';

class Firestore {
  final db = FirebaseFirestore.instance;

  String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

// set a document by giving the whole path:
  void setPreferredPhotoMethod(UserPreferences preferredPhotoMethod) {
    final id = preferredPhotoMethod.id;
    final docuReference = db.doc('users/$id/preferredPhotoMethod/method');
    docuReference
        .set(preferredPhotoMethod.toMap())
        .onError((e, stackTrace) => devtools.log("Error writing document: $e"));
  }

  Future<bool> getUpdatedPreferredPhotoMethod(String userId) async {
    devtools.log('getUpdatedPreferredPhotoMethod was called');
    bool value = false;
    var data = await db
        .collection("users")
        .doc(userId)
        .collection("preferredPhotoMethod")
        .doc('method')
        .get()
        .then((value) => value.data());

    if (data != null) {
      for (var d in data.values) {
        devtools.log('d is: $d');
        value = d;
      }
    }
    return value;
  }


  Future<List<String>> showListOfUserDocuments() async {
    List<String> docsList = [];

    final thing = await db.collection("users").get();

    final otherThing = thing.docs;
    for (var doc in otherThing) {
      docsList.add(doc.id);
      devtools.log(doc.id);
    }

    return docsList;
  }
}
