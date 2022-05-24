import 'package:cosapp/models/inspections.dart';
import 'package:cosapp/services/database/firestore.dart';
import 'package:cosapp/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

import 'edit_inspections.dart';

class VehicleInspectionOverviewView extends StatefulWidget {
  const VehicleInspectionOverviewView({Key? key}) : super(key: key);

  @override
  State<VehicleInspectionOverviewView> createState() =>
      _VehicleInspectionOverviewViewState();
}

class _VehicleInspectionOverviewViewState
    extends State<VehicleInspectionOverviewView> {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Firestore>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          IconButton(
              onPressed: () => ProfileView.show(context),
              icon: const Icon(Icons.supervised_user_circle)),
        ],
      ),
      body: StreamBuilder<List<Inspections>>(
        stream: database.inspectionsStream(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Inspections>> snapshot) {
          if (snapshot.hasData) {
            final inspections = snapshot.data;
            final children = inspections
                ?.map(
                  (inspection) => InspectionsListTile(
                    inspections: inspection,
                    onTap: () => EditInspectionsPage.show(context,
                        inspections: inspection),
                  ),
                )
                .toList();
            return ListView(
              children: children!,
            );
          }
          if (snapshot.hasError) {
            devtools.log(snapshot.error.toString());
            return Center(
              child: Text('${snapshot.error}'),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => EditInspectionsPage.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class InspectionsListTile extends StatelessWidget {
  const InspectionsListTile(
      {Key? key, required this.inspections, required this.onTap})
      : super(key: key);

  final Inspections inspections;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(inspections.vehicleIdNumber),
      trailing: const Icon(Icons.arrow_circle_right_outlined),
      onTap: onTap,
    );
  }
}
