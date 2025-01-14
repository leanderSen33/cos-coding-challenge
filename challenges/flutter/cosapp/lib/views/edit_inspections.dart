import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../models/inspections.dart';
import '../services/database/firestore.dart';

import '../services/sorage/storage_service.dart';
import '../widgets/show_exception_dialog.dart';
import 'dart:developer' as devtools show log;

class EditInspectionsPage extends StatefulWidget {
  const EditInspectionsPage(
      {Key? key, required this.database, required this.inspections})
      : super(key: key);

  final Inspections? inspections;
  final Firestore database;

  static Future<void> show(BuildContext context,
      {Inspections? inspections}) async {
    final database = Provider.of<Firestore>(context, listen: false);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditInspectionsPage(
          inspections: inspections,
          database: database,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<EditInspectionsPage> createState() => _EditInspectionsPageState();
}

class _EditInspectionsPageState extends State<EditInspectionsPage> {
  // final FocusNode _nameFocusNode = FocusNode();
  // final FocusNode _ratePerHourFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  // String? _name;
  // int? _ratePerHour;
  final storage = StorageService();
  DateTime? _inspectionDate;
  String? _vehicleIdNumber;
  String? _vehicleMake;
  String? _vehicleModel;
  String? _photoCarURL;

  @override
  void initState() {
    super.initState();
    if (widget.inspections != null) {
      _inspectionDate = widget.inspections?.inspectionDate;
      _vehicleIdNumber = widget.inspections?.vehicleIdNumber;
      _vehicleMake = widget.inspections?.vehicleMake;
      _vehicleModel = widget.inspections?.vehicleModel;
      _photoCarURL = widget.inspections?.photo;
    }
  }

  // @override
  // void dispose() {
  //   _nameFocusNode.dispose();
  //   _ratePerHourFocusNode.dispose();
  //   super.dispose();
  // }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        final id = widget.inspections?.id ??
            widget.database.documentIdFromCurrentDate();
        final inspection = Inspections(
          id: id,
          inspectionDate: _inspectionDate!,
          vehicleIdNumber: _vehicleIdNumber!,
          vehicleMake: _vehicleMake,
          vehicleModel: _vehicleModel,
          photo: _photoCarURL,
        );
        devtools.log('vehicle photo ${inspection.photo}');
        await widget.database.setInspection(inspection);
        Navigator.of(context).pop();
        // }
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: 'Operation failed', exception: e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () async {
              if (_validateAndSaveForm()) {
                devtools.log(_validateAndSaveForm().toString());
                Navigator.of(context).pop();
              } else {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text('Please fill out all required fields'),
                  ),
                );
              }
            },
          ),
          actions: [
            TextButton(
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _submit,
            )
          ],
          elevation: 2.0,
          title: Text(widget.inspections == null
              ? 'New Inspection'
              : 'Edit Inspection'),
        ),
        body: _buildContents(),
      ),
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildFormChildren()),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      InputDatePickerFormField(
        initialDate: DateTime.now(),
        errorInvalidText: 'Please try again. Date cannot be in the future',
        fieldLabelText: 'Inspection Date',
        onDateSaved: (value) => _inspectionDate = value,
        firstDate: DateTime(DateTime.now().year - 10),
        lastDate: DateTime.now(),
      ),
      TextFormField(
        initialValue: _vehicleIdNumber != null ? "$_vehicleIdNumber" : null,
        decoration: const InputDecoration(labelText: 'Vehicle ID number'),
        onSaved: (value) => _vehicleIdNumber = value,
        validator: (value) => vehicleIDNumberValidator(value!),
        inputFormatters: [UpperCaseTextFormatter()],
      ),
      TextFormField(
        initialValue: _vehicleMake != null ? "$_vehicleMake" : null,
        decoration: const InputDecoration(labelText: 'Vehicle make (optional)'),
        onSaved: (value) => _vehicleMake = value,
      ),
      TextFormField(
        initialValue: _vehicleModel != null ? "$_vehicleModel" : null,
        decoration:
            const InputDecoration(labelText: 'Vehicle model (optional)'),
        onSaved: (value) => _vehicleModel = value,
      ),
      Row(
        children: [
          const Text('choose a photo (optional)'),
          IconButton(
            onPressed: () async {
              _photoCarURL = await storage.addCarPhotoAndGetBackItsURL(context);
            },
            icon: const Icon(Icons.photo),
          ),
        ],
      ),
    ];
  }

  String? vehicleIDNumberValidator(String value) {
    if (value.isEmpty) {
      setState(() {});
      return "This field cannot be empty";
    } else if (value.length != 17) {
      setState(() {});
      return "This number must contain 17 characters";
    } else if (value.contains('I') ||
        value.contains('O') ||
        value.contains('U')) {
      setState(() {});
      return "Cannot contain I, O, U characters";
    }
    return null;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
