import 'package:bouldr/utils/authentication.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({Key? key}) : super(key: key);
  final TextEditingController textControllerDisplayName =
      TextEditingController();
  final TextEditingController textControllerEmail = TextEditingController();
  final TextEditingController textControllerPass1 = TextEditingController();
  final TextEditingController textControllerPass2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Sign Up'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
                controller: textControllerDisplayName,
                textAlignVertical: TextAlignVertical.center,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  isCollapsed: true,
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Display Name',
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 5)),
                )),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
                controller: textControllerEmail,
                textAlignVertical: TextAlignVertical.center,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  isCollapsed: true,
                  prefixIcon: Icon(Icons.email),
                  hintText: 'Email',
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 5)),
                )),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: textControllerPass1,
                textAlignVertical: TextAlignVertical.center,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  isCollapsed: true,
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Password',
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 5)),
                )),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: textControllerPass2,
                textAlignVertical: TextAlignVertical.center,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  isCollapsed: true,
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Re-enter password',
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 5)),
                )),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
                width: double.infinity, // <-- match_parent
                child: ElevatedButton(
                  child: Text('Submit'),
                  onPressed: () => {
                    if (textControllerEmail.text != "" &&
                        textControllerDisplayName.text != "" &&
                        textControllerPass1.text != "" &&
                        textControllerPass1.text == textControllerPass2.text)
                      {
                        AuthenticationHelper()
                            .signUp(
                                email: textControllerEmail.text,
                                password: textControllerPass1.text,
                                displayName: textControllerDisplayName.text)
                            .then((result) {
                          if (result == null) {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "Sign up successfull",
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: result,
                            );
                          }
                        })
                      }
                    else
                      {
                        if (textControllerDisplayName.text == "")
                          {
                            Fluttertoast.showToast(
                              msg: "Must enter display name",
                            )
                          }
                        else if (textControllerEmail.text == "")
                          {
                            Fluttertoast.showToast(
                              msg: "Must enter email address",
                            )
                          }
                        else if (textControllerPass1.text == "")
                          {
                            Fluttertoast.showToast(
                              msg: "Must enter password",
                            )
                          }
                        else if (textControllerPass1.text !=
                            textControllerPass2.text)
                          {
                            Fluttertoast.showToast(
                              msg: "Passwords do not match",
                            )
                          }
                      }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(fontSize: 20)),
                )),
          ),
        ],
      ),
    );
  }
}
