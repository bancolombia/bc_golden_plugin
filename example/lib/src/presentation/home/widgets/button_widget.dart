import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(elevation: MaterialStateProperty.all(10)),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Text(
            "CIBSANS",
            style: TextStyle(
              fontFamily: 'CIBFontSans-Light',
            ),
          ),
          Text(
            "ROBOTO",
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
