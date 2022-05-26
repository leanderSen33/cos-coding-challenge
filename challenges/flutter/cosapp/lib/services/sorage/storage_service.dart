import 'dart:io';

import 'package:cosapp/services/auth/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:image_picker/image_picker.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();
  final storageRef = FirebaseStorage.instance;
  late File file;

  final currentUser = AuthService.firebase().currentUser;

  // in order to give each user access to its specific data, we will use the user id.
  Future<void> uploadProfilePhotoFile(File file) async {
    final profileImagesRef =
        storageRef.ref().child('user/profile/${currentUser?.id}');
    try {
      await profileImagesRef.putFile(file).then(
            (_) => devtools.log('uploading file, done'),
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

  Future<String?> addCarPhotoAndGetBackItsURL(BuildContext context) async {
    String? downloadedURL;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

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
        final photoID = await uploadCarPhotoFile(file);
        devtools.log('photoID: $photoID');
        downloadedURL = await getCarpotoURL(photoID);
        devtools.log('downloaded URL: $downloadedURL');
      }
    } catch (e) {
      devtools.log(e.toString());
    }
    return downloadedURL;
  }

  Future<String> uploadCarPhotoFile(File file) async {
    final id = DateTime.now().toIso8601String();
    final carImagesRef = storageRef.ref().child('user/cars/$id');
    devtools.log('car images ref: ${carImagesRef.toString()}');

    try {
      await carImagesRef.putFile(file).then(
            (_) => devtools.log('uploading file, done'),
          );
    } on FirebaseException catch (e) {
      devtools.log(e.toString());
    }
    return id;
  }

  Future<String> getCarpotoURL(String id) async {
    String results = 'nothing';
    try {
      String path = 'user/cars/$id';
      // devtools.log('downloading path: ${path.toString()}');
      results = await storageRef.ref(path).getDownloadURL();
    } on FirebaseException catch (e) {
      devtools.log('Downloading ERROR: ${e.toString()}');
    }
    return results;
  }

  Future<void> changeProfilePhoto(
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

        await uploadProfilePhotoFile(file);
        final downloadedURL = await getPhotoProfileURL();
        devtools.log('downloaded URL: $downloadedURL');
      }
    } catch (e) {
      devtools.log(e.toString());
    }
  }
}
