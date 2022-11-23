import 'dart:developer' as devtools show log;

import 'package:cosapp/views/password_page.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:provider/provider.dart';

import 'package:cosapp/services/auth/auth_service.dart';
import 'package:cosapp/services/sorage/storage_service.dart';

import '../models/user_preferences.dart';
import '../services/database/firestore.dart';
import '../widgets/dialogs.dart';

enum PhotoMethod { camera, gallery }

class ProfileView extends StatefulWidget {
  const ProfileView({
    Key? key,
    required this.firestore,
  }) : super(key: key);

  final Firestore firestore;

  static Future<void> show(BuildContext context) async {
    final database = Provider.of<Firestore>(context, listen: false);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileView(
          firestore: database,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final storage = StorageService();
  final _auth = AuthService.firebase();
  bool _isCameraMethodPreferred = false;

  @override
  Widget build(BuildContext context) {
    devtools.log('build method\'s been initialized');
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF464A56),
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              height: 250,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 30,
                        right: double.infinity,
                      ),
                      child: IconButton(
                        color: const Color(0xFF464A56),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    FutureBuilder<String?>(
                      future: storage.getPhotoProfileURL(),
                      builder: (BuildContext context,
                          AsyncSnapshot<String?> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 80,
                            width: 80,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.black26,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black, //<-- SEE HERE
                              ),
                            ),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          if (snapshot.hasData) {
                            return Avatar(
                              snapshot: snapshot.data!,
                              onPressed: changePhoto,
                            );
                          } else {
                            return const CircleAvatar(
                              radius: 70.0,
                              backgroundImage:
                                  AssetImage('assets/avatar_placeholder.png'),
                            );
                          }
                        } else {
                          return Text('State: ${snapshot.connectionState}');
                        }
                      },
                    ),
                    Text(
                      "Hi ${AuthService.firebase().currentUser?.email}! Nice to see you again.",
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () => PasswordPage.show(context),
              child: const Text('Change password'),
            ),
            TextButton(
              onPressed: () async {
                final shouldLogOut = await showLogOutDialog(context);
                if (shouldLogOut) {
                  await AuthService.firebase().logOut();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  void changePhoto() async {
    var buttonWasPressed = false;
    await Dialogs.materialDialog(
        msg: 'Upload image from:',
        color: Colors.white,
        context: context,
        actions: [
          IconsOutlineButton(
            onPressed: () {
              selectPhotoMethod(PhotoMethod.gallery);
              buttonWasPressed = true;
              Navigator.pop(context);
            },
            text: 'file',
            iconData: Icons.folder,
            textStyle: const TextStyle(color: Colors.grey),
            iconColor: Colors.grey,
          ),
          IconsOutlineButton(
            onPressed: () {
              selectPhotoMethod(PhotoMethod.camera);
              buttonWasPressed = true;
              Navigator.pop(context);
            },
            text: 'camera',
            iconData: Icons.camera_alt,
            // color: Colors.red,
            textStyle: const TextStyle(color: Colors.grey),
            iconColor: Colors.grey,
          ),
        ]);

    buttonWasPressed
        ? await storage.changeProfilePhoto(context, _isCameraMethodPreferred)
        : null;
    setState(() {});
  }

  void selectPhotoMethod(PhotoMethod method) {
    if (method == PhotoMethod.camera) {
      setState(() {
        _isCameraMethodPreferred = true;
        setPhotoMethod(widget.firestore);
      });
    } else {
      setState(() {
        _isCameraMethodPreferred = false;
        setPhotoMethod(widget.firestore);
      });
    }
  }

  void setPhotoMethod(Firestore firestore) {
    devtools.log('setPhotoMethod\'s been called');
    final userPreference = UserPreferences(
        id: _auth.currentUser!.id, preferCamera: _isCameraMethodPreferred);
    firestore.setPreferredPhotoMethod(userPreference);
  }
}

class Avatar extends StatelessWidget {
  Avatar({
    required this.snapshot,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  String snapshot;
  VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      CircleAvatar(
        radius: 70.0,
        backgroundImage: NetworkImage(snapshot),
      ),
      IconButton(onPressed: onPressed, icon: const Icon(Icons.edit)),
    ]);
  }
}
