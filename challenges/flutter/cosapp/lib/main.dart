import 'package:cosapp/views/login_view.dart';
import 'package:flutter/material.dart';
import 'constants/routes.dart';
import 'views/profile_view.dart';
import 'views/vehicle_inspection_overview_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: loginRoute,
      routes: {
        // TODO: implement a way (landing page) to show the profile view if the user is already logged in
        //! Check Andrea's lesson: 134 Preview of the Sign in...13  qwe
        loginRoute: (context) => const LogInView(title: 'login'),
        profileRoute: (context) => const ProfileView(),
        overviewRoute: (context) =>  const VehicleInspectionOverviewView(),
        // '/vehicleinspectiondetailspage/': (context) => ,
      },
    ),
  );
}
