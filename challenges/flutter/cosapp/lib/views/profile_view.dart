import 'package:flutter/material.dart';

import 'package:cosapp/constants/routes.dart';
import 'package:cosapp/services/auth/auth_service.dart';
import 'package:image_picker/image_picker.dart';

import '../enums/menu_action.dart';
import '../widgets/dialogs.dart';
import 'dart:developer' as devtools show log;

class ProfileView extends StatelessWidget {
  ProfileView({Key? key}) : super(key: key);
  final ImagePicker _picker = ImagePicker();
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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
                  Avatar(
                    avatarUrl: null,
                    onTap: () async {
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      devtools.log('${image?.path}');
                    },
                  ),
                  Text(
                      "Hi ${AuthService.firebase().currentUser?.email} nice to see you here.'}"),
                ],
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(hintText: "Username"),
                    ),
                    const SizedBox(height: 20.0),
                    // Expanded(
                    //   child: Column(
                    //     children: <Widget>[
                    //       Text(
                    //         "Manage Password",
                    //         style: Theme.of(context).textTheme.display1,
                    //       ),
                    //       TextFormField(
                    //         decoration: InputDecoration(hintText: "Password"),
                    //       ),
                    //       TextFormField(
                    //         decoration:
                    //             InputDecoration(hintText: "New Password"),
                    //       ),
                    //       TextFormField(
                    //         decoration:
                    //             InputDecoration(hintText: "Repeat Password"),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    // RaisedButton(
                    //   onPressed: () {
                    //     // TODO: Save somehow
                    //     Navigator.pop(context);
                    //   },
                    //   child: Text("Save Profile"),
                    // )
                  ],
                ),
              ))
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
