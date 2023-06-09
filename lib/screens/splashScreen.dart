import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../appwrite/auth_api.dart';
import 'LoginScreen.dart';
import 'homeScreen.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool loading = true;


  
  gotoScreen(Widget destination){
    Timer(
        const Duration(seconds: 3),
        (){
             Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => destination));
          });
  }
  
  @override
  Widget build(BuildContext context) {
    final value = context.watch<AuthAPI>().status;
    value == AuthStatus.uninitialized
        ?  loading=true
        : value == AuthStatus.authenticated
        ?  gotoScreen(HomeScreen())
        :  gotoScreen(LoginScreen());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/habit_pro_logo.svg',
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20,),
            CircularProgressIndicator(color: Colors.white,)
          ],
        ),
      ),
    );
  }
}
