import 'dart:io';

import 'package:cosapp/services/auth/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:image_picker/image_picker.dart';

//TODO: configure imagePicker for IOS. We have to edit the plist or somthing

class StorageService {
  final ImagePicker _picker = ImagePicker();
  final storageRef = FirebaseStorage.instance;
  late File file;

  // TODO: What is the problem with this? why should I use getIt or other dependency injection method?
  final currentUser = AuthService.firebase().currentUser;

  // in order to give each user access to its specific data, we will use the user id.
  Future<void> uploadFile(File file) async {
    final profileImagesRef =
        storageRef.ref().child('user/profile/${currentUser?.id}');

    try {
      await profileImagesRef.putFile(file).then(
            (p0) => devtools.log('uploading file, done'),
          );
    } on FirebaseException catch (e) {
      devtools.log(e.toString());
    }
  }

  Future<String> getPhotoProfileURL() async {
    final results = await storageRef
        .ref('user/profile/${currentUser?.id}')
        .getDownloadURL();
    return results;
  }

  Future<void> changePhoto(
      BuildContext context, bool isCameraMethodPreferred) async {
    try {
      final XFile? image = await _picker.pickImage(
          source: isCameraMethodPreferred
              ? ImageSource.camera
              : ImageSource.gallery);

      if (image == null) {
        devtools.log('No image was selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file selected'),
          ),
        );
      } else {
        devtools.log('Path of the selected image: ${image.path}');
        file = File(image.path);

        await uploadFile(file);
        final downloadedURL = await getPhotoProfileURL();
        devtools.log('downloaded URL: $downloadedURL');
      }
    } catch (e) {
      devtools.log(e.toString());
    }
  }
}
