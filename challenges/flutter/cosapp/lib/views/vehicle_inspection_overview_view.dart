import 'package:cosapp/models/inspections.dart';
import 'package:cosapp/services/database/firestore.dart';
import 'package:cosapp/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

            return ListTileInspections(inspections: inspections);
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

//TODO: move to widgets folder
//TODO: test with an empy list of inspections
class ListTileInspections extends StatelessWidget {
  const ListTileInspections({
    Key? key,
    required this.inspections,
  }) : super(key: key);

  final List<Inspections>? inspections;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: ((context, index) {
        int reversedIndex = inspections!.length - 1 - index;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          child: ListTile(
            tileColor: Colors.amber,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            //TODO: put the photo here
            leading: Container(
              padding: const EdgeInsets.only(right: 12.0),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    width: 1.0,
                    color: Color.fromARGB(60, 145, 55, 55),
                  ),
                ),
              ),
              child: const Icon(
                Icons.autorenew,
                color: Color.fromARGB(255, 138, 93, 93),
              ),
            ),
            title: Text(
              'VIN: ${inspections![reversedIndex].vehicleIdNumber}',
              style: const TextStyle(
                  color: Color.fromARGB(255, 48, 23, 23),
                  fontWeight: FontWeight.bold),
            ),
            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      inspections![reversedIndex].vehicleMake!,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 64, 72, 164),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      inspections![reversedIndex].vehicleModel!,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 64, 72, 164),
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat.yMd()
                      .format(inspections![reversedIndex].inspectionDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),

            trailing: const Icon(
              Icons.keyboard_arrow_right,
              color: Color.fromARGB(255, 159, 29, 29),
              size: 30.0,
            ),
          ),
        );
      }),
      itemCount: inspections!.length,
    );
  }
}
