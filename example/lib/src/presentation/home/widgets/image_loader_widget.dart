import 'package:flutter/material.dart';

class ImageLoaderWidget extends StatelessWidget {
  const ImageLoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      '../assets/LogoBancolombia.png',
      filterQuality: FilterQuality.medium,
    );
  }
}
