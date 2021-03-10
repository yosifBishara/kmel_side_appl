import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kmel_side_app/home.dart';
import 'package:kmel_side_app/loading.dart';
import 'package:kmel_side_app/view_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    initialRoute: '/home',
    routes: {
      '/' : (context) => HomePage(),
      '/home' : (context) => HomePage(),
      '/view' : (context) => AppView(),
      '/load' : (context) => LoadingScreen(),
    },

  ));
}
