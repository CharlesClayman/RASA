import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../providers/google_sign_in.dart';

class SignInMethods extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
          left: size.width * 0.1,
          right: size.width * 0.1,
          top: size.width * 0.03,
          bottom: size.width * 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                shape: BoxShape.circle,
              ),
              child: Image.asset("assets/icons/facebook.png"),
            ),
          ),
          SizedBox(
            width: size.width * 0.1,
          ),
          GestureDetector(
            onTap: () {
              final provider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.Login();
            },
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                shape: BoxShape.circle,
              ),
              child: Image.asset("assets/icons/google-symbol.png"),
            ),
          )
        ],
      ),
    );
  }
}
