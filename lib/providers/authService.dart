import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<bool> email_SignUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      return Future.value(true);
    } catch (e) {
      print("EMAIL ERROR" + e);
    }
  }

  Future<bool> email_SignIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return Future.value(true);
    } on FirebaseAuthException catch (e) {
      print("My Sign In " + e.code);
      return Future.value(false);
    }
  }

  Future signInWithGoogle() async {
    try {
      // trigger authentication Flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      print(googleUser);

      if (googleUser != null) {
        // Obtaining auth details from request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        print(googleAuth);

        //Creating new credentials
        final GoogleAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
        print(credential);

        User user = (await _auth.signInWithCredential(credential)).user;
        print(user);
      }
    } catch (e) {
      print(e);
    }
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("user signed out");
  }
}
