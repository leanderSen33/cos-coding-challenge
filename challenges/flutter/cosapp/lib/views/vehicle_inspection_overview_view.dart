import 'package:cosapp/models/inspections.dart';
import 'package:cosapp/services/database/firestore.dart';
import 'package:cosapp/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

import '../widgets/list_tile_inspections.dart';
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
      backgroundColor: const Color(0xFF464A56),
      appBar: AppBar(
        title: const Text('Vehicle Inspections'),
        actions: [
          IconButton(
            onPressed: () => ProfileView.show(context),
            icon: const Icon(Icons.account_circle_sharp),
          ),
        ],
      ),
      body: StreamBuilder<List<Inspections>>(
        stream: database.inspectionsStream(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Inspections>> snapshot) {
          if (snapshot.hasData) {
            final inspections = snapshot.data;

            return ListTileInspections(
              inspections: inspections,
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
