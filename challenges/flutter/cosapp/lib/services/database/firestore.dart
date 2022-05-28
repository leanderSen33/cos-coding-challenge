import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cosapp/models/inspections.dart';

import 'dart:developer' as devtools show log;

import 'package:cosapp/models/user_preferences.dart';

class Firestore {
  Firestore({required this.uid});
  final String uid;

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
    devtools
        .log('getUpdatedPreferredPhotoMethod was called (firestore_service)');
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
        value = d;
      }
    }
    return value;
  }

  Future<List<String>> getListOfUserDocuments() async {
    List<String> docsList = [];

    final thing = await db.collection("users").get();

    final otherThing = thing.docs;
    for (var doc in otherThing) {
      docsList.add(doc.id);
      devtools.log(doc.id);
    }
    return docsList;
  }

  Future<void> setInspection(Inspections inspections) => _setData(
        path: 'vehicle_inspections/$uid/inspections/${inspections.id}',
        data: inspections.toMap(),
      );

  Future<void> _setData(
      {required String path, required Map<String, dynamic> data}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    devtools.log('$path: $data');
    await reference.set(data);
  }

  Stream<List<Inspections>> inspectionsStream() =>
      collectionStream<Inspections>(
        path: 'vehicle_inspections/$uid/inspections',
        builder: (data, documentId) => Inspections.fromMap(data, documentId),
      );

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
  }) {
    final reference = FirebaseFirestore.instance.collection(path);
    final snaposhots = reference.snapshots();
    return snaposhots.map((snapshot) => snapshot.docs
        .map(
          (snapshot) => builder(snapshot.data(), snapshot.id),
        )
        .toList());
  }
}
