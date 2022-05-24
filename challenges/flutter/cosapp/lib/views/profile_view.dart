import 'dart:developer' as devtools show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:cosapp/services/auth/auth_service.dart';
import 'package:cosapp/services/sorage/storage_service.dart';
import 'package:cosapp/views/login_view.dart';

import '../enums/menu_action.dart';
import '../models/user_preferences.dart';
import '../services/database/firestore.dart';
import '../widgets/dialogs.dart';

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
  late File file;
  final ImagePicker _picker = ImagePicker();
  final storage = StorageService();
  // final firestore = Firestore(uid: );
  final _auth = AuthService.firebase();
  String downloadedURL = 'https://dummyimage.com/300.png/09f/fff';
  bool isCameraMethodPreferred = false;

  bool checkCurrentPasswordValid = true;
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (!isKeyboard)
              Expanded(
                child: Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          FutureBuilder<String>(
                            future: storage.getFile(),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              return CircleAvatar(
                                radius: 70.0,
                                backgroundImage: NetworkImage(snapshot.data ??
                                    'https://dummyimage.com/300.png/09f/fff'),
                              );
                            },
                          ),
                          PopupMenuButton<MenuAction>(
                            onSelected: chooseAction,
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
                      Text(
                        "Hi ${AuthService.firebase().currentUser?.email}! Nice to see you again.",
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const Text(
                      "Change password",
                      // style: Theme.of(context).textTheme.display1,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          hintText: "Current password",
                          errorText: checkCurrentPasswordValid
                              ? null
                              : "Please double check your current password"),
                      controller: _passwordController,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(hintText: "New Password"),
                      controller: _newPasswordController,
                      obscureText: true,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(hintText: "Repeat Password"),
                      controller: _repeatPasswordController,
                      obscureText: true,
                      validator: (value) {
                        return _newPasswordController.text == value
                            ? null
                            : "Please validate your entered password";
                      },
                    ),
                    TextButton(
                      onPressed: () async {
                        checkCurrentPasswordValid = await _auth
                            .validateCurrentPassword(_passwordController.text);
                        setState(() {});

                        if (_formKey.currentState!.validate() &&
                            checkCurrentPasswordValid) {
                          _auth.updatePassword(_newPasswordController.text);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Save Profile"),
                    ),
                  ],
                ),
              ),
            ),
            if (!isKeyboard)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () async {
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
                              devtools.log(
                                  'Path of the selected image: ${image.path}');
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
                        child: const Text(
                          'Change photo',
                        ),
                      ),
                      Column(
                        children: [
                          FutureBuilder<bool>(
                            future: widget.firestore
                                .getUpdatedPreferredPhotoMethod(
                                    _auth.currentUser!.id),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              return Column(
                                children: [
                                  const Text('Preferred photo method:'),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                    child: FlutterSwitch(
                                      inactiveIcon: const Icon(Icons.folder),
                                      activeIcon: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                      inactiveColor: Colors.grey,
                                      activeColor: Colors.grey,
                                      toggleColor: Colors.black,
                                      inactiveToggleColor: Colors.white,
                                      width: 90.0,
                                      height: 33.0,
                                      valueFontSize: 17.0,
                                      toggleSize: 45.0,
                                      value: snapshot.data ?? true,
                                      borderRadius: 30.0,
                                      padding: 4.0,
                                      onToggle: (value) {
                                        setState(() {
                                          isCameraMethodPreferred = value;
                                          setPhotoMethod(widget.firestore);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void setPhotoMethod(Firestore firestore) {
    devtools.log('setPhotoMethod\'s been called');
    final userPreference = UserPreferences(
        id: _auth.currentUser!.id, preferCamera: isCameraMethodPreferred);
    firestore.setPreferredPhotoMethod(userPreference);
  }

  void chooseAction(value) async {
    switch (value) {
      case MenuAction.logout:
        final shouldLogOut = await showLogOutDialog(context);
        if (shouldLogOut) {
          await AuthService.firebase().logOut();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
    }
  }
}
