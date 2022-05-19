import 'package:cosapp/views/login_view.dart';
import 'package:flutter/material.dart';
import 'constants/routes.dart';
import 'views/profile_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: loginRoute,
      routes: {
        loginRoute: (context) => const LogInView(title: 'login'),
        profileRoute: (context) => const ProfileView(),
        // '/vehicleinspectionoverviewpage/': (context) =>,
        // '/vehicleinspectiondetailspage/': (context) => ,
      },
    ),
  );
}
