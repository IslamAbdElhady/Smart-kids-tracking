import 'package:flutter/material.dart';
import 'package:kinder_garten/Screens/Home_screen.dart';
import 'package:kinder_garten/Screens/old_LogIn_screen.dart';
import 'package:kinder_garten/Screens/LogIn_Screen.dart';
import 'package:splashscreen/splashscreen.dart'as sp;


class SplashScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return sp.SplashScreen(
      gradientBackground: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff55ffff),Color(0xff89cff0)],
      ),
      image: Image(
        image: AssetImage("assets/images/logo.png"),
      ),
      photoSize: MediaQuery.of(context).size.width*.3,
      seconds: 3,
      navigateAfterSeconds: LogInScreen(title: "KinderGarten",),
      loaderColor: Colors.white,
      loadingText: Text(
        "Starting Kinder Garten App",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

