import 'dart:io';

import 'package:cosapp/services/sorage/storage_service.dart';
import 'package:flutter/material.dart';

import 'package:cosapp/constants/routes.dart';
import 'package:cosapp/services/auth/auth_service.dart';
import 'package:image_picker/image_picker.dart';

import '../enums/menu_action.dart';
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
  String downloadedURL =
      'https://firebasestorage.googleapis.com/v0/b/cos-challenge.appspot.com/o/user%2Fprofile%2FrYeD0NqxqeZwhabKywtPqn6jfGh1?alt=media&token=777f53db-b4c0-4f82-b865-7957fea52799';
  bool isCameraMethodPreferred = false;
  var storage = StorageService();

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
          Avatar(
            avatarUrl: downloadedURL,
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
                  devtools.log('Path of the selected image: ${image.path}');
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
          ),
          Column(
            children: [
              const Text('From Album / From Camera'),
              Switch.adaptive(
                onChanged: (value) {
                  setState(() {
                    isCameraMethodPreferred = value;
                    print('value $value');
                  });
                },
                value: isCameraMethodPreferred,
              ),
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
