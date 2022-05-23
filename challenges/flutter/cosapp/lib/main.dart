import 'package:cosapp/views/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const LandingPage(),
      // initialRoute: loginRoute,
      // routes: {
      //   // TODO: implement a way (landing page) to show the profile view if the user is already logged in
      //   //! Check Andrea's lesson: 134 Preview of the Sign in...13  qwe
      //   loginRoute: (context) => const LogInView(title: 'login'),
      //   profileRoute: (context) => const ProfileView(),
      //   overviewRoute: (context) =>  const VehicleInspectionOverviewView(),
      //   // '/vehicleinspectiondetailspage/': (context) => ,
      // },
    ),
  );
}
