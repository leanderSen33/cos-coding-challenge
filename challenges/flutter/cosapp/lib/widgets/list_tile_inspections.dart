import 'package:flutter/material.dart';
import '../models/inspections.dart';
import 'package:intl/intl.dart';
import '../views/edit_inspections.dart';
import 'dart:developer' as devtools show log;

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
        devtools
            .log('Vehicle Make: ${inspections?[reversedIndex].vehicleMake}');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 7,
            child: ListTile(
              minLeadingWidth: 65,
              isThreeLine: true,
              tileColor: Colors.grey[200],
              contentPadding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () => EditInspectionsPage.show(
                context,
                inspections: inspections![reversedIndex],
              ),
              leading: LeadingWidget(
                inspections: inspections,
                reversedIndex: reversedIndex,
              ),
              title: TitleWidget(
                inspections: inspections,
                reversedIndex: reversedIndex,
              ),
              subtitle: SubtitleWidget(
                inspections: inspections,
                reversedIndex: reversedIndex,
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
      height: double.infinity,
      padding: const EdgeInsets.only(right: 10.0),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            width: 1.0,
            color: Color.fromARGB(60, 145, 55, 55),
          ),
        ),
      ),
      child: inspections![reversedIndex].photo == null
          ? const Icon(
              Icons.car_crash_outlined,
              color: Color.fromARGB(255, 138, 93, 93),
            )
          : Image.network(inspections![reversedIndex].photo!),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    Key? key,
    required this.inspections,
    required this.reversedIndex,
  }) : super(key: key);

  final List<Inspections>? inspections;
  final int reversedIndex;

  @override
  Widget build(BuildContext context) {
    return Text(
      'VIN: ${inspections![reversedIndex].vehicleIdNumber}',
      style: TextStyle(
        color: Colors.grey[800],
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class SubtitleWidget extends StatelessWidget {
  const SubtitleWidget({
    Key? key,
    required this.inspections,
    required this.reversedIndex,
  }) : super(key: key);

  final List<Inspections>? inspections;
  final int reversedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(
          height: 8,
        ),
        Text(
          DateFormat.yMd().format(inspections![reversedIndex].inspectionDate),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
