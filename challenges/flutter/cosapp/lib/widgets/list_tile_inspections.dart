import 'package:flutter/material.dart';
import '../models/inspections.dart';
import 'package:intl/intl.dart';
import '../views/edit_inspections.dart';
// import 'dart:developer' as devtools show log;

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
          padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Material(
              child: InkWell(
                onTap: () => EditInspectionsPage.show(
                  context,
                  inspections: inspections![reversedIndex],
                ),
                child: Ink(
                  height: 90,
                  color: Colors.grey[200],
                  child: Row(
                    children: <Widget>[
                      Container(
                        color: Colors.black54,
                        width: 90,
                        height: 90,
                        child: LeadingWidget(
                          inspections: inspections,
                          reversedIndex: reversedIndex,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'VIN: ${inspections![reversedIndex].vehicleIdNumber}',
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              '${inspections![reversedIndex].vehicleMake!}  ${inspections![reversedIndex].vehicleModel!}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              DateFormat.yMd().format(
                                  inspections![reversedIndex].inspectionDate),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
      itemCount: inspections!.length,
    );
  }
}

class LeadingWidget extends StatelessWidget {
  const LeadingWidget({
    Key? key,
    required this.inspections,
    required this.reversedIndex,
  }) : super(key: key);

  final List<Inspections>? inspections;
  final int reversedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: inspections![reversedIndex].photo == null
          ? Padding(
              padding: const EdgeInsets.all(7.0),
              child: Image.asset('assets/car_placeholder.png'),
            )
          : Image.network(
              inspections![reversedIndex].photo!,
              fit: BoxFit.cover,
            ),
    );
  }
}
