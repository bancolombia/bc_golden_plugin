import 'package:flutter/material.dart';

import '../home/home_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'CIBFontSans-Light',
      ),
      home: const HomePage(title: 'Flutter Demo Home'),
    );
  }
}
