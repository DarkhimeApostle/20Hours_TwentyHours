import 'package:TwentyHours/screens/root_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const TwentyHours());
}

class TwentyHours extends StatelessWidget {
  const TwentyHours({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TwentyHours', // 项目名字
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C3E50)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // 移除DEBUG标签
      home: const RootScreen(),
    );
  }
}
