import 'dart:io';

import 'package:cosapp/services/sorage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

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
  late File file;
  final ImagePicker _picker = ImagePicker();
  final storage = StorageService();
  final firestore = Firestore();
  final _auth = AuthService.firebase();
  String downloadedURL = 'https://dummyimage.com/300.png/09f/fff';
  bool isCameraMethodPreferred = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_auth.currentUser?.email}"),
        actions: [
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            "Hi ${AuthService.firebase().currentUser?.email}! Nice to see you again.",
          ),
          FutureBuilder<String>(
            future: storage.getFile(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return CircleAvatar(
                radius: 90.0,
                backgroundImage: NetworkImage(
                    snapshot.data ?? 'https://dummyimage.com/300.png/09f/fff'),
              );
            },
          ),
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
            child: const Text(
              'Change photo',
            ),
          ),
          Column(
            children: [
              FutureBuilder<bool>(
                future: firestore
                    .getUpdatedPreferredPhotoMethod(_auth.currentUser!.id),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                              setPhotoMethod();
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
    );
  }

  void setPhotoMethod() {
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
          Navigator.of(context).pushNamedAndRemoveUntil(
            loginRoute,
            (route) => false,
          );
        }
    }
  }
}





//  Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Theme.of(context).primaryColor,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(20.0),
//                   bottomRight: Radius.circular(20.0),
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   Avatar(
//                     avatarUrl: _currentUser?.avatarUrl,
//                     onTap: () {},
//                   ),
//                   Text(
//                       "Hi ${_currentUser?.displayName ?? 'nice to see you here.'}"),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//               flex: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   children: <Widget>[
//                     TextFormField(
//                       decoration: InputDecoration(hintText: "Username"),
//                     ),
//                     SizedBox(height: 20.0),
//                     Expanded(
//                       child: Column(
//                         children: <Widget>[
//                           Text(
//                             "Manage Password",
//                             style: Theme.of(context).textTheme.display1,
//                           ),
//                           TextFormField(
//                             decoration: InputDecoration(hintText: "Password"),
//                           ),
//                           TextFormField(
//                             decoration:
//                                 InputDecoration(hintText: "New Password"),
//                           ),
//                           TextFormField(
//                             decoration:
//                                 InputDecoration(hintText: "Repeat Password"),
//                           )
//                         ],
//                       ),
//                     ),
//                     RaisedButton(
//                       onPressed: () {
//                         // TODO: Save somehow
//                         Navigator.pop(context);
//                       },
//                       child: Text("Save Profile"),
//                     )
//                   ],
//                 ),
//               ))
//         ],
//       ),
    
