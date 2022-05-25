import 'package:cloud_firestore/cloud_firestore.dart';

class Inspections {
  Inspections({
    required this.id,
    required this.inspectionDate,
    required this.vehicleIdNumber,
    this.vehicleMake,
    this.vehicleModel,
    this.photo,
  });

  final String id;
  final DateTime inspectionDate;
  final String vehicleIdNumber;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? photo;

  factory Inspections.fromMap(Map<String, dynamic> data, String documentId) {
    Timestamp inspectionDateFromFirebase = data['inspection_date'];
    final DateTime inspectionDate = inspectionDateFromFirebase.toDate();
    final String vehicleNumber = data['vehicle_number'] ?? '';
    final String vehicleMake = data['vehicle_make'];
    final String? vehicleModel = data['vehicle_model'];
    final String? photo = data['photo'];

    return Inspections(
        id: documentId,
        inspectionDate: inspectionDate,
        vehicleIdNumber: vehicleNumber,
        vehicleMake: vehicleMake,
        vehicleModel: vehicleModel,
        photo: photo);
  }

  Map<String, dynamic> toMap() => {
        'inspection_date': Timestamp.fromDate(inspectionDate),
        'vehicle_number': vehicleIdNumber,
        'vehicle_make': vehicleMake,
        'vehicle_model': vehicleModel,
        'photo': photo,
      };
}


  // to get documents: static String Inspection(String uid, String jobId) => 'vehicle_inspections/$uid';

  // to get list: static String Inspection(String uid, String jobId) => 'vehicle_inspections';


// Date of inspection (required) - Date cannot be in the future
// Vehicle Identification Number (required) - must be exactly 17 characters. Cannot contain I, O, U characters. Can only contain numbers and letters.
// Vehicle make (optional)
// Vehicle model (optional)
// Vehicle photo (optional)