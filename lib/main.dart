import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kmel_side_app/current_vacations.dart';
import 'package:kmel_side_app/date_for_view_page.dart';
import 'package:kmel_side_app/home.dart';
import 'package:kmel_side_app/loading.dart';
import 'package:kmel_side_app/view_page.dart';
import 'add_vacation.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    initialRoute: '/home',
    routes: {
      '/' : (context) => HomePage(),
      '/home' : (context) => HomePage(),
      '/preViewDate': (context) => DateForViewPage(),
      '/view' : (context) => AppView(),
      '/currentVacations': (context) => CurrentVacations(),
      '/addVacation': (context) => AddVacation(),
      '/load' : (context) => LoadingScreen(),
    },

  ));
}
