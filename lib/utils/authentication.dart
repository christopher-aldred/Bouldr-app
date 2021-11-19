import 'package:bouldr/pages/login.dart';
import 'package:bouldr/pages/sign_up.dart';
import 'package:bouldr/repository/data_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;
  DataRepository dr = DataRepository();

  void loginDialogue(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(
                _auth.currentUser == null
                    ? 'User account'
                    : "User: " + _auth.currentUser!.displayName.toString(),
                textAlign: TextAlign.center,
              ),
              content: _auth.currentUser == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SignUpPage()));
                                  },
                                  child: Text('Sign Up'))),
                          SizedBox(width: 20),
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()));
                                  },
                                  child: Text('Login'))) // button 2
                        ])
                  : ElevatedButton(
                      onPressed: () => {Navigator.pop(context), signOut()},
                      child: Text('Logout'),
                    ));
        });
  }

  //SIGN UP METHOD
  Future signUp(
      {required String email,
      required String password,
      required String displayName}) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then((result) => {
                result.user!.updateDisplayName(displayName),
                dr.addUserDisplayName(result.user!.uid, displayName)
              });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //SIGN IN METHOD
  Future signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //SIGN OUT METHOD
  Future signOut() async {
    await _auth.signOut();

    print('signout');
  }

  //FORGOTTEN PASS
  Future forgottenPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
