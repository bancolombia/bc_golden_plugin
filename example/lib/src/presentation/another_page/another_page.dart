import 'package:flutter/material.dart';

class AnotherPage extends StatelessWidget {
  const AnotherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Another Page',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'CIBFontSans-Light',
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Welcome to Another Page!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            fontFamily: 'CIBFontSans-Light',
          ),
        ),
      ),
    );
  }
}
