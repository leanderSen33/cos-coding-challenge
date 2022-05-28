import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cosapp/services/auth/auth_service.dart';
import 'package:cosapp/services/sorage/storage_service.dart';
import 'package:cosapp/widgets/custom_fields.dart';

import '../enums/menu_action.dart';
import '../models/user_preferences.dart';
import '../services/database/firestore.dart';
import '../widgets/change_photo_button.dart';
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
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCameraMethodPreferred = false;
  bool _checkCurrentPasswordValid = true;


  @override
  Widget build(BuildContext context) {
    devtools.log('build method\'s been initialized');
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFF464A56),
          resizeToAvoidBottomInset: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (!isKeyboard)
                SizedBox(
                  height: 200,
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
                              color: const Color(0xFF464A56),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back_rounded),
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
                                    return CircleAvatar(
                                      radius: 70.0,
                                      backgroundImage:
                                          NetworkImage(snapshot.data!),
                                    );
                                  } else {
                                    return const CircleAvatar(
                                      radius: 70.0,
                                      backgroundImage: AssetImage(
                                          'assets/avatar_placeholder.png'),
                                    );
                                  }
                                } else {
                                  return Text(
                                      'State: ${snapshot.connectionState}');
                                }
                              },
                            ),
                            PopupMenuButton<MenuAction>(
                              icon: const Icon(
                                Icons.menu,
                                color: Color(0xFF464A56),
                              ),
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
              if (!isKeyboard)
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: <Widget>[
                      FutureBuilder<bool>(
                        future: widget.firestore.getUpdatedPreferredPhotoMethod(
                            _auth.currentUser!.id),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            _isCameraMethodPreferred = snapshot.data;
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Photo method',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.folder),
                                    color: _isCameraMethodPreferred
                                        ? Colors.grey
                                        : const Color(0xFFFDBF11),
                                    disabledColor: const Color.fromARGB(
                                        255, 111, 111, 111),
                                    onPressed: snapshot.hasData
                                        ? () => selectPhotoMethod(
                                            PhotoMethod.gallery)
                                        : null,
                                  ),
                                  IconButton(
                                      icon: const Icon(Icons.camera_alt),
                                      color: _isCameraMethodPreferred
                                          ? const Color(0xFFFDBF11)
                                          : Colors.grey,
                                      disabledColor: const Color.fromARGB(
                                          255, 111, 111, 111),
                                      onPressed: snapshot.hasData
                                          ? () => selectPhotoMethod(
                                              PhotoMethod.camera)
                                          : null),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  ChangePhotoTextButton(
                                    save: changePhoto,
                                    activateButton:
                                        snapshot.hasData ? true : false,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // const SizedBox(height: 10),
                      const Text(
                        "Change password",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      CustomTextFormField(
                        title: 'password',
                        textController: _passwordController,
                        isObscure: false,
                        errorText: "Please double check your current password",
                        checkCurrentPasswordValid: _checkCurrentPasswordValid,
                      ),
                      const SizedBox(height: 12),
                      CustomTextFormField(
                        title: 'new password',
                        textController: _newPasswordController,
                        isObscure: true,
                      ),
                      const SizedBox(height: 12),
                      CustomTextFormField(
                        title: 'repeat password',
                        textController: _repeatPasswordController,
                        isObscure: true,
                        validator: (value) {
                          return _newPasswordController.text == value
                              ? null
                              : "Please validate your entered password";
                        },
                      ),
                      TextButton(
                        child: const Text("Save password changes"),
                        onPressed: () async {
                          _checkCurrentPasswordValid =
                              await _auth.validateCurrentPassword(
                                  _passwordController.text);
                          setState(() {});
                          if (_formKey.currentState!.validate() &&
                              _checkCurrentPasswordValid) {
                            _auth.updatePassword(_newPasswordController.text);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changePhoto() async {
    await storage.changeProfilePhoto(context, _isCameraMethodPreferred);
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
