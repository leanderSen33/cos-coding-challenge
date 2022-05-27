import 'package:cosapp/widgets/custom_fields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cosapp/services/auth/auth_service.dart';
import 'package:cosapp/services/sorage/storage_service.dart';

import '../enums/menu_action.dart';
import '../models/user_preferences.dart';
import '../services/database/firestore.dart';
import '../widgets/custom_switch.dart';
import '../widgets/dialogs.dart';
import 'dart:developer' as devtools show log;

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
  Future<String?>? _photoProfile;
  Future<bool>? _photoMethodPreference;

  @override
  void initState() {
    _photoProfile = storage.getPhotoProfileURL();
    _photoMethodPreference =
        widget.firestore.getUpdatedPreferredPhotoMethod(_auth.currentUser!.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                              future: _photoProfile,
                              builder: (BuildContext context,
                                  AsyncSnapshot<String?> snapshot) {
                                devtools.log(
                                    'PhotoProfile state: ${snapshot.connectionState.toString()}');

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
                        future: _photoMethodPreference,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
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
                                  CustomSwitch(
                                    snapshot: snapshot.data,
                                    switchPhotoMethod: switchPhotoMethod,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  ChangePhotoTextButton(
                                    save: changePhoto,
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

  void switchPhotoMethod(bool value) {
    setState(
      () {
        _isCameraMethodPreferred = value;
        setPhotoMethod(widget.firestore);
      },
    );
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

class ChangePhotoTextButton extends StatelessWidget {
  const ChangePhotoTextButton({
    Key? key,
    required this.save,
  }) : super(key: key);

  final VoidCallback save;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33,
      child: TextButton(
        child: const Text(
          'Change photo',
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: Colors.grey,
        ),
        onPressed: save,
      ),
    );
  }
}
