import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:habit_pro/screens/splashScreen.dart';
import 'package:provider/provider.dart';
import 'appwrite/auth_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
      create: ((context) => AuthAPI()),
      child: MaterialApp(
        theme: ThemeData(),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      )));
}

