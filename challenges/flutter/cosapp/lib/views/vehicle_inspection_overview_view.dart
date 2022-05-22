import 'package:cosapp/constants/routes.dart';
import 'package:flutter/material.dart';

class VehicleInspectionOverviewView extends StatelessWidget {
  const VehicleInspectionOverviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  profileRoute,
                );
              },
              icon: const Icon(Icons.supervised_user_circle)),
        ],
      ),
      body: Container(),
    );
  }
}
