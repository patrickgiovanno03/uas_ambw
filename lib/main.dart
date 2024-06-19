import 'package:flutter/material.dart';
import '../homepage.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('hiveNote');
  await Hive.openBox('hivePassword');
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Lexend'),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
