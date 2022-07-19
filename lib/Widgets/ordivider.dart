import 'package:flutter/material.dart';

class Ordivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
        left: size.width * 0.1,
        right: size.width * 0.1,
      ),
      width: size.width * 0.8,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              height: 1.5,
              color: Colors.white,
            ),
          ),
          Text(
            "OR",
            style: TextStyle(color: Colors.white),
          ),
          Expanded(
            child: Divider(
              height: 1.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
