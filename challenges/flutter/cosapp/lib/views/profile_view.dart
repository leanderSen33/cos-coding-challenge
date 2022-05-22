import 'dart:io';

import 'package:cosapp/services/sorage/storage_service.dart';
import 'package:flutter/material.dart';

import 'package:cosapp/constants/routes.dart';
import 'package:cosapp/services/auth/auth_service.dart';
import 'package:image_picker/image_picker.dart';

import '../enums/menu_action.dart';
import '../models/user_preferences.dart';
import '../services/database/firestore.dart';
import '../widgets/dialogs.dart';
import 'dart:developer' as devtools show log;

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker _picker = ImagePicker();
  late File file;
  String downloadedURL = 'https://dummyimage.com/300.png/09f/fff';
  bool isCameraMethodPreferred = false;
  final storage = StorageService();

  final firestore = Firestore();

  final id = AuthService.firebase().currentUser?.id;

  void setPhotoMethod() {
    devtools.log('setPhotoMethod\'s been called');
    final userPreference =
        UserPreferences(id: id!, preferCamera: isCameraMethodPreferred);
    firestore.setPreferredPhotoMethod(userPreference);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile Page'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  if (shouldLogOut) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                )
              ];
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FutureBuilder<String>(
              future: storage.getFile(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return Avatar(
                  avatarUrl:
                      snapshot.data ?? 'https://dummyimage.com/300.png/09f/fff',
                  onTap: () async {
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
                        devtools
                            .log('Path of the selected image: ${image.path}');
                        file = File(image.path);

                        await storage.uploadFile(file);
                        downloadedURL = await storage.getFile();
                        devtools.log('downloaded URL: $downloadedURL');
                        setState(() {});
                      }
                    } catch (e) {
                      devtools.log(e.toString());
                    }
                  },
                );
              }),
          Column(
            children: [
              FutureBuilder<bool>(
                  future: firestore.getUpdatedPreferredPhotoMethod(id!),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return Column(
                      children: [
                        Text(snapshot.data.toString()),
                        Switch.adaptive(
                          onChanged: (value) {
                            setState(() {
                              isCameraMethodPreferred = value;
                              setPhotoMethod();
                              // print('value $value');
                            });
                          },
                          value: snapshot.data ?? true,
                        ),
                      ],
                    );
                  }),
              const Text('From Album / From Camera'),
            ],
          ),
          Text(
              // TODO: Refactor this.
              "Hi ${AuthService.firebase().currentUser?.email} nice to see you here."),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onTap;

  const Avatar({
    Key? key,
    required this.avatarUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: avatarUrl == null
            ? const CircleAvatar(
                radius: 50.0,
                child: Icon(Icons.photo_camera),
              )
            : CircleAvatar(
                radius: 50.0,
                backgroundImage: NetworkImage(avatarUrl!),
              ),
      ),
    );
  }
}
