import 'package:cosapp/models/inspections.dart';
import 'package:cosapp/services/database/firestore.dart';
import 'package:cosapp/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final database = Provider.of<Firestore>(context, listen: false);
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
      body: StreamBuilder<List<Inspections>>(
        stream: database.inspectionsStream(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Inspections>> snapshot) {
          if (snapshot.hasData) {
            final jobs = snapshot.data;
            final children = jobs
                ?.map(
                  (job) => InspectionsListTile(
                    inspections: job,
                    onTap: () =>
                        EditInspectionsPage.show(context, inspections: job),
                  ),
                )
                .toList();
            return (ListView(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children!,
            ));
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('There is some error'),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      // body: FutureBuilder<List<String>>(
      //   future: firestore.showListOfUserDocuments(),
      //   builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
      //     var list = snapshot.data?.map((item) => Text(item)).toList();

      //     return (ListView(
      //       children: list ?? [const Text('Loading')],
      //     ));

      //     // for (var d in asyncSnapshot.data) {
      //     //   return Text(d);
      //     // }
      //   },
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
      ),
    );
  }
}
