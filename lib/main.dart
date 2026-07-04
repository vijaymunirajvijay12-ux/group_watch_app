import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GroupWatchApp());
}

class GroupWatchApp extends StatelessWidget {
  const GroupWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Watch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
