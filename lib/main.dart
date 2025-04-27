import 'package:flutter/material.dart';
import 'group_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share the Tab',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GroupScreen(),
    );
  }
}