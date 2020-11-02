import 'package:flutter/material.dart';
import 'package:relojcin_binario/src/pages/HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "RelojcinWifi",
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
        primaryColor: Colors.lightBlueAccent,
        primaryColorDark: Colors.indigoAccent
      ),
    );
  }
}
