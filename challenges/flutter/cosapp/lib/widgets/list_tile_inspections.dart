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
                        color: Colors.red,
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

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemBuilder: ((context, index) {
//         int reversedIndex = inspections!.length - 1 - index;

//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
//           child: Card(
//             child: ListTile(
//               minLeadingWidth: 65,
//               isThreeLine: true,
//               tileColor: Colors.grey[200],
//               contentPadding: const EdgeInsets.all(0),
// onTap: () => EditInspectionsPage.show(
//   context,
//   inspections: inspections![reversedIndex],
// ),
//               leading: LeadingWidget(
//                 inspections: inspections,
//                 reversedIndex: reversedIndex,
//               ),
//               title: TitleWidget(
//                 inspections: inspections,
//                 reversedIndex: reversedIndex,
//               ),
//               subtitle: SubtitleWidget(
//                 inspections: inspections,
//                 reversedIndex: reversedIndex,
//               ),
//             ),
//           ),
//         );
//       }),
//       itemCount: inspections!.length,
//     );
//   }
// }

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
          ? const Icon(
              Icons.car_crash_outlined,
              color: Color.fromARGB(255, 138, 93, 93),
            )
          : Image.network(
              inspections![reversedIndex].photo!,
              fit: BoxFit.fill,
            ),
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
