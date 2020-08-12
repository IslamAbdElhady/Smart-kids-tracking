import 'package:flutter/material.dart';
import 'package:kinder_garten/Screens/Home_screen.dart';
import 'package:kinder_garten/Screens/LogIn_Screen.dart';
import 'package:kinder_garten/Screens/Splash_screen.dart';

void main(){
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        title: 'KinderGarten',
        debugShowCheckedModeBanner: false,
        home: LogInScreen(title: "KinderGarten",),
    );
  }
}
