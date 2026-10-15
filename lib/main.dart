import 'package:flutter/material.dart';
import 'View/loginpage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mhasla Wheels',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'DMSans',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF103B33)),
      scaffoldBackgroundColor: const Color(0xFFF7F5EC),
    ),
    home: const LoginPage(),
  );
}
