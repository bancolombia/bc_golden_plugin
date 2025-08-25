import 'package:example/src/presentation/home/widgets/button_widget.dart';
import 'package:flutter/material.dart';

import '../another_page/another_page.dart';
import 'widgets/image_loader_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'CIBFontSans-Light',
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const ImageLoaderWidget(),
            ButtonWidget(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnotherPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
