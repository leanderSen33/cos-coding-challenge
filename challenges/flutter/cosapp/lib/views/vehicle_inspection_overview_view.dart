import 'package:cosapp/constants/routes.dart';
import 'package:cosapp/models/user_preferences.dart';
import 'package:cosapp/services/database/firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth/auth_service.dart';

class VehicleInspectionOverviewView extends StatefulWidget {
  const VehicleInspectionOverviewView({Key? key}) : super(key: key);

  @override
  State<VehicleInspectionOverviewView> createState() =>
      _VehicleInspectionOverviewViewState();
}

class _VehicleInspectionOverviewViewState
    extends State<VehicleInspectionOverviewView> {
  final firestore = Firestore();

  void setPhotoMethod() {
    final id = AuthService.firebase().currentUser?.id;
    final userPreference = UserPreferences(id: id!, preferCamera: true);

    firestore.setPreferredPhotoMethod(userPreference);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  profileRoute,
                );
              },
              icon: const Icon(Icons.supervised_user_circle)),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: firestore.showListOfUserDocuments(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          var list = snapshot.data?.map((item) => Text(item)).toList();

          return (ListView(
            children: list ?? [const Text('Loading')],
          ));

          // for (var d in asyncSnapshot.data) {
          //   return Text(d);
          // }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            setPhotoMethod();
          });
        },
      ),
    );
  }
}
