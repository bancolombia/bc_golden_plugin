import 'package:flutter/material.dart';

class ImageLoaderWidget extends StatelessWidget {
  const ImageLoaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      '../assets/sponge_bob.png',
      filterQuality: FilterQuality.medium,
    );
  }
}
