import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../models/inspections.dart';
import '../services/database/firestore.dart';

import '../widgets/dialogs.dart';
import '../widgets/show_alert_dialog.dart';
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

  DateTime? _inspectionDate;
  String? _vehicleIdNumber;
  String? _vehicleMake;
  String? _vehicleModel;
  String? _photo;

  // void _nameEditingComplete() {
  //   final newFocus = _formKey.currentState!.validate()
  //       ? _ratePerHourFocusNode
  //       : _nameFocusNode;
  //   FocusScope.of(context).requestFocus(newFocus);
  // }

  @override
  void initState() {
    super.initState();
    if (widget.inspections != null) {
      _inspectionDate = widget.inspections?.inspectionDate;
      _vehicleIdNumber = widget.inspections?.vehicleIdNumber;
      _vehicleMake = widget.inspections?.vehicleMake;
      _vehicleModel = widget.inspections?.vehicleModel;
      _photo = widget.inspections?.photo;
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
        //TODO: Finish this
        // // Stream.first gets the first (most up-to-date) value on the stream
        // final inspections = await widget.database.inspectionsStream().first;
        // final allNames =
        //     inspections.map((inspection) => inspection.name).toList();
        // // this will exclude the job name from the list of existing jobs (to avoid getting the error message when we want to edit a job, without changing the name)
        // if (widget.inspections != null) {
        //   allNames.remove(widget.inspections?.name);
        // }
        // if (allNames.contains(_name)) {
        //   showAlertDialog(context,
        //       title: 'Name already used',
        //       content: 'Please choose a different name',
        //       defaultActionText: 'OK');
        // } else {
        // When we're creating new job id will be null, so we will use this documentIdF... Function,
        // when we're editing (job id will be not null) we will use the existing id
        final id = widget.inspections?.id ??
            widget.database.documentIdFromCurrentDate();
        final inspection = Inspections(
          id: id,
          inspectionDate: _inspectionDate!,
          vehicleIdNumber: _vehicleIdNumber!,
          vehicleMake: _vehicleMake,
          vehicleModel: _vehicleModel,
        );
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () async {
            if (_validateAndSaveForm()) {
              devtools.log(_validateAndSaveForm().toString());
              _submit();
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
            ? 'New Inspections'
            : 'Edit Inspections'),
      ),
      body: _buildContents(),
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
        errorInvalidText: 'Please try again. Date cannot be in the future',
        fieldLabelText: 'Inspection Date',
        onDateSaved: (value) => _inspectionDate = value,
        initialDate: DateTime.now(),
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
        decoration: const InputDecoration(labelText: 'Vehicle make (opt.)'),
        onSaved: (value) => _vehicleMake = value,
      ),
      TextFormField(
        initialValue: _vehicleModel != null ? "$_vehicleModel" : null,
        decoration: const InputDecoration(labelText: 'Vehicle model (opt.)'),
        onSaved: (value) => _vehicleModel = value,
      ),
      // ImageFormField(buttonBuilder: (){}, initializeFileAsImage: (File ) {  }, previewImageBuilder: (BuildContext , ) {  },),
      // Row(
      //   children: [
      //     const Text('photo'),
      //     IconButton(
      //       onPressed: () {},
      //       icon: const Icon(Icons.photo),
      //     ),
      //   ],
      // ),
    ];
  }

  String? vehicleIDNumberValidator(String value) {
    if (value.isEmpty) {
      return "This field cannot be empty";
    } else if (value.length != 17) {
      return "This number must contain 17 characters";
    } else if (value.contains('I') ||
        value.contains('O') ||
        value.contains('U')) {
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
