import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MototaxiApp());
}

class MototaxiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mototaxi 24 Horas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
