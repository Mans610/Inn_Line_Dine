import 'package:flutter/material.dart';
import 'package:inn_dine_hub/Screens/splash.dart';

void main() {
  runApp(const MyApp());
}
String appName = 'InnDineHub';
Color pColor =  const Color(0xffF2D99F);
Color sColor =  const Color(0xff137276);
Color s1Color = Colors.cyan;
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}




