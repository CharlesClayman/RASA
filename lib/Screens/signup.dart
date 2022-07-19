import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/authService.dart';

import '../Widgets/shadermask.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<Signup> {
  String _username;
  String _email;
  String _password;
  String _confirmPassword;
  final auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _snackbarkey = GlobalKey<ScaffoldState>();
  Size size;

  ////Defining TextEditingControllers for the TextFormField
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Shadermask("assets/background/bg.gif"),
        Scaffold(
            backgroundColor: Colors.transparent,
            body: ListView(
              children: [
                SizedBox(
                  height: 30.0,
                ),
                Center(
                    child: CircleAvatar(
                  radius: size.width * 0.15,
                  child: Icon(
                    FontAwesomeIcons.user,
                    color: Colors.white,
                    size: size.width * 0.12,
                  ),
                )),
                Form(
                  key: _formkey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      _usernameTextFormField(),
                      _emailTextFormField(),
                      _passwordTextFormField(),
                      _confirmPasswordTextFormField(),
                      _submitButton(),
                    ],
                  ),
                ),
              ],
            ))
      ],
    );
  }

  Widget _usernameTextFormField() {
    return Container(
      padding: EdgeInsets.only(top: 3),
      margin: EdgeInsets.only(
          top: size.width * 0.1,
          left: size.width * 0.1,
          right: size.width * 0.1,
          bottom: size.width * 0.04),
      height: 55,
      width: size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.grey[500].withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _usernameController,
        validator: (String value) {
          if (value.isEmpty) {
            return "Field is empty";
          } else {
            return null;
          }
        },
        onSaved: (String value) {
          setState(() {
            _username = value;
          });
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(
                FontAwesomeIcons.user,
                size: 20,
                color: Colors.white,
              ),
            ),
            labelText: "Name",
            contentPadding: EdgeInsets.only(top: 3, left: 10.0)
            //labelStyle: TextStyle(height: 1),
            ),
        style: TextStyle(color: Colors.white, fontSize: 18),
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _emailTextFormField() {
    return Container(
      padding: EdgeInsets.only(top: 3),
      margin: EdgeInsets.only(
          left: size.width * 0.1,
          right: size.width * 0.1,
          bottom: size.width * 0.04),
      height: 55,
      width: size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.grey[500].withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _emailController,
        validator: (String value) {
          if (value.isEmpty) {
            return "Field is empty";
          } else {
            return null;
          }
        },
        onSaved: (String value) {
          setState(() {
            _email = value;
          });
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(
                FontAwesomeIcons.envelope,
                size: 20,
                color: Colors.white,
              ),
            ),
            labelText: "Email",
            contentPadding: EdgeInsets.only(top: 3, left: 10.0)),
        style: TextStyle(color: Colors.white, fontSize: 18),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _passwordTextFormField() {
    return Container(
      padding: EdgeInsets.only(top: 3),
      margin: EdgeInsets.only(
          left: size.width * 0.1,
          right: size.width * 0.1,
          bottom: size.width * 0.04),
      height: 55,
      width: size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.grey[500].withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _passwordController,
        validator: (String value) {
          if (value.isEmpty) {
            return "Field is empty";
          } else {
            return null;
          }
        },
        onSaved: (String value) {
          setState(() {
            _password = value;
          });
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(
                FontAwesomeIcons.lock,
                size: 20,
                color: Colors.white,
              ),
            ),
            labelText: "Password",
            contentPadding: EdgeInsets.only(top: 3, left: 10.0)),
        style: TextStyle(color: Colors.white, fontSize: 18),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _confirmPasswordTextFormField() {
    return Container(
      padding: EdgeInsets.only(top: 3),
      margin: EdgeInsets.only(
          left: size.width * 0.1,
          right: size.width * 0.1,
          bottom: size.width * 0.1),
      height: 55,
      width: size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.grey[500].withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _confirmPasswordController,
        validator: (String value) {
          if (value.isEmpty) {
            return "Field is empty";
          } else {
            return null;
          }
        },
        onSaved: (String value) {
          setState(() {
            if (_confirmPasswordController.toString().trim() !=
                _passwordController.toString().trim()) {}
          });
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(
                FontAwesomeIcons.lock,
                size: 20,
                color: Colors.white,
              ),
            ),
            labelText: "Confirm Password",
            contentPadding: EdgeInsets.only(top: 3, left: 10.0)),
        style: TextStyle(color: Colors.white, fontSize: 18),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        textInputAction: TextInputAction.done,
      ),
    );
  }

  Widget _submitButton() {
    return Container(
        margin:
            EdgeInsets.only(left: size.width * 0.25, right: size.width * 0.25),
        child: Builder(builder: (BuildContext newContext) {
          return RaisedButton(
              onPressed: () {
                _formkey.currentState.validate();
                _formkey.currentState.save();
                if (_email.isNotEmpty && _password.isNotEmpty) {
                  AuthService().email_SignUp(_email, _password).whenComplete(
                      () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Login())));
                }
              },
              shape: StadiumBorder(),
              padding: EdgeInsets.all(0.0),
              child: Container(
                child: Text(
                  "SIGNUP",
                  style: TextStyle(color: Colors.white),
                ),
                padding: EdgeInsets.symmetric(horizontal: 65.0, vertical: 15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    gradient: LinearGradient(colors: [
                      Color.fromRGBO(26, 21, 0, 0.8),
                      Color.fromRGBO(221, 255, 51, 0.8),
                    ])),
              ));
        }));
  }
}
