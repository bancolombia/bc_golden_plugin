import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(elevation: WidgetStateProperty.all(10)),
      onPressed: () {},
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'CIBSANS',
            style: TextStyle(
              fontFamily: 'CIBFontSans-Light',
            ),
          ),
          Text(
            'ROBOTO',
            style: TextStyle(
              fontFamily: 'Roboto-Regular',
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.abc),
        ],
      ),
    );
  }
}
