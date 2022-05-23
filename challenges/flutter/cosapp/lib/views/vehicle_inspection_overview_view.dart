import 'package:cosapp/services/database/firestore.dart';
import 'package:cosapp/views/profile_view.dart';
import 'package:flutter/material.dart';



class VehicleInspectionOverviewView extends StatefulWidget {
  const VehicleInspectionOverviewView({Key? key}) : super(key: key);

  @override
  State<VehicleInspectionOverviewView> createState() =>
      _VehicleInspectionOverviewViewState();
}

class _VehicleInspectionOverviewViewState
    extends State<VehicleInspectionOverviewView> {
  final firestore = Firestore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileView()),
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
          setState(() {});
        },
      ),
    );
  }
}
