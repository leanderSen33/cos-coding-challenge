import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/inspections.dart';
import '../services/database/firestore.dart';

// We need to create the New Inspections page, so we will have some state.
// We have 3 options, we can create a Stateful widget with local variables.

// a Data type + Change notifier, or a BLoC. For now we'll make it simple, and go
// with a Stateful widget.

class EditInspectionsPage extends StatefulWidget {
  const EditInspectionsPage({Key? key, required this.database, required this.inspections})
      : super(key: key);

  final Inspections? inspections;

  final Firestore database;
  // Code so that we can present this page when the FAB is pressed.
  // this push a new route inside the navigation stack
  static Future<void> show(BuildContext context, {Inspections? job}) async {
    final database = Provider.of<Firestore>(context, listen: false);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditInspectionsPage(
          inspections: job,
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
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _ratePerHourFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  String? _name;
  int? _ratePerHour;

  void _nameEditingComplete() {
    final newFocus = _formKey.currentState!.validate()
        ? _ratePerHourFocusNode
        : _nameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  @override
  void initState() {
    super.initState();
    if (widget.inspections != null) {
      _name = widget.inspections?.name;
      _ratePerHour = widget.inspections?.ratePerHour;
    }
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _ratePerHourFocusNode.dispose();
    super.dispose();
  }

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
        // Stream.first gets the first (most up-to-date) value on the stream
        final jobs = await widget.database.jobsStream().first;
        final allNames = jobs.map((job) => job.name).toList();
        // this will exclude the job name from the list of existing jobs (to avoid getting the error message when we want to edit a job, without changing the name)
        if (widget.inspections != null) {
          allNames.remove(widget.inspections?.name);
        }
        if (allNames.contains(_name)) {
          showAlertDialog(context,
              title: 'Name already used',
              content: 'Please choose a different name',
              defaultActionText: 'OK');
        } else {
          // When we're creating new job id will be null, so we will use this documentIdF... Function,
          // when we're editing (job id will be not null) we will use the existing id
          final id = widget.inspections?.id ?? documentIdFromCurrentDate();
          final job = Inspections(name: _name, ratePerHour: _ratePerHour, id: id);
          await widget.database.setInspections(job);
          Navigator.of(context).pop();
        }
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
        title: Text(widget.inspections == null ? 'New Inspections' : 'Edit Inspections'),
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
          children: _buildFormChildre()),
    );
  }

  List<Widget> _buildFormChildre() {
    return [
      // NAME
      TextFormField(
        initialValue: _name,
        onEditingComplete: _nameEditingComplete,
        focusNode: _nameFocusNode,
        decoration: const InputDecoration(labelText: 'Inspections Name'),
        onSaved: (value) => _name = value!,
        validator: (value) => value!.isNotEmpty ? null : 'Name can\'t be empty',
      ),
      // RATE PER HOUR
      TextFormField(
        initialValue: _ratePerHour != null ? "$_ratePerHour" : null,
        onEditingComplete: _submit,
        focusNode: _ratePerHourFocusNode,
        decoration: const InputDecoration(labelText: 'Rate per hour'),
        // we must use tryParse instead of parse, because .parse returns an exception when the operation fails.
        // otoh, tryParse returns null if can't parse the value. And we handle that case with the ?? operator.
        onSaved: (value) => _ratePerHour = int.tryParse(value!) ?? 0,
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
      )
    ];
  }
}
