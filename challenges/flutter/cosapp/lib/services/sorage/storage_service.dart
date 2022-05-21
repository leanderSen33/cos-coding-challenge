import 'dart:io';

import 'package:cosapp/services/auth/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

//TODO: configure imagePicker for IOS. We have to edit the plist or somthing

class StorageService {
  final storageRef = FirebaseStorage.instance;

  // TODO: What is the problem with this? why should I use getIt or other dependency injection method?
  final currentUser = AuthService.firebase().currentUser;

  // in order to give each user access to its specific data, we will use the user id.
  Future<void> uploadFile(File file) async {
    final profileImagesRef =
        storageRef.ref().child('user/profile/${currentUser?.id}');

    try {
      await profileImagesRef.putFile(file).then(
            (p0) => print('done'),
          );
    } on FirebaseException catch (e) {
      print(e);
    }
  }


  Future<String> getFile() async {
    final results = await storageRef
        .ref('user/profile/${currentUser?.id}')
        .getDownloadURL();
    return results;
  }

  // final downloadURL = await uploadTask.ref.getDownloadURL();
  // return downloadURL;
}
