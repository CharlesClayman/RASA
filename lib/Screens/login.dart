import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_safety/providers/authService.dart';

import 'signup.dart';
import 'homepage.dart';
import '../Widgets/shadermask.dart';
import '../Widgets/signinmethods.dart';
import 'package:provider/provider.dart';
import '../providers/google_sign_in.dart';
import '../Widgets/ordivider.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<Login> {
  String _email;
  String _password;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  Size size;
  //Defining TextEditingControllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //for facebook login
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  //String _message = 'Log in/out by pressing the buttons below.';

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Stack(children: [
      Shadermask("assets/background/bg.gif"),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          children: [
            SizedBox(
              height: 20.0,
            ),
            Container(
              margin: EdgeInsets.only(
                  top: size.width * 0.1,
                  left: size.width * 0.1,
                  right: size.width * 0.1,
                  bottom: size.width * 0.1),
              child: Image.asset(
                "assets/images/applogo.png",
                width: 150,
                height: 150,
              ),
            ),
            Form(
              key: formkey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  _emailTextFormField(),
                  _passwordTextFormField(),
                  GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.only(
                            left: size.width * 0.1,
                            right: size.width * 0.1,
                            bottom: size.width * 0.04),
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "Forgot Password ?",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )),
                  _submitButton(),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(
                  top: size.width * 0.07,
                  left: size.width * 0.1,
                  right: size.width * 0.1,
                  bottom: size.width * 0.04),
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Signup())),
                  child: Text(
                    "Don't have an account ? Sign Up",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
            Ordivider(),
            // SignInMethods(),
            Container(
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
                    onTap: () {
                      _handleLogin();
                    },
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
                    onTap: () async {
                      final provider = Provider.of<GoogleSignInProvider>(
                          context,
                          listen: false);
                      provider.Login();

                      FirebaseAuth auth = FirebaseAuth.instance;
                      await AuthService().signInWithGoogle().then((value) {
                        print(value);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      });
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
            )
          ],
        ),
      )
    ]);
  }

  Widget buildLoading() => Center(
        child: CircularProgressIndicator(),
      );

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
            return "Email field is empty";
          } else {
            return null;
          }
        },
        onSaved: (String value) {
          _email = value.trim();
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 3, left: 10.0),
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
        ),
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
            return "Password field is empty";
          } else {
            return null;
          }
        },
        onSaved: (String value) {
          _password = value.trim();
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 3, left: 10.0),
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
        ),
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
        child: RaisedButton(
            onPressed: () {
              formkey.currentState.validate();
              formkey.currentState.save();

              if (_email.isNotEmpty && _password.isNotEmpty) {
                AuthService().email_SignIn(_email, _password).then((value) {
                  if (value) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => HomePage()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Email or Password is incorrect")));
                  }
                });
              }
            },
            shape: StadiumBorder(),
            padding: EdgeInsets.all(0.0),
            child: Container(
              child: Text(
                "LOGIN",
                style: TextStyle(color: Colors.white),
              ),
              padding: EdgeInsets.symmetric(horizontal: 65.0, vertical: 15.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  gradient: LinearGradient(colors: [
                    Color.fromRGBO(26, 21, 0, 0.8),
                    Color.fromRGBO(221, 255, 51, 0.8),
                  ])),
            )));
  }

  Future _handleLogin() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        final _credential =
            FacebookAuthProvider.credential(result.accessToken.token);
        User user = (await auth.signInWithCredential(_credential)).user;
        if (user.providerData.isNotEmpty)
          print("MY CRED...." + user.providerData.toString());
        else
          print("...............No Data");
        /* Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage())); */

        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
      default:
    }
  }

  Future<bool> _loginWithFacebook(
      FacebookLoginResult _result, BuildContext context) async {
    FacebookAccessToken _accessToken = _result.accessToken;
    AuthCredential _credential =
        FacebookAuthProvider.credential(_accessToken.token);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
    await auth.signInWithCredential(_credential);

    return Future.value(true);
  }
}
