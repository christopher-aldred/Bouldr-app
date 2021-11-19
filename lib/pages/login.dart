import 'package:bouldr/utils/authentication.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  final TextEditingController textControllerUsername = TextEditingController();
  final TextEditingController textControllerEmail = TextEditingController();
  final TextEditingController textControllerPass1 = TextEditingController();
  final TextEditingController textControllerPass2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Login'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: TextField(
                controller: textControllerEmail,
                textAlignVertical: TextAlignVertical.center,
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                decoration: InputDecoration(
                  isCollapsed: true,
                  prefixIcon: Icon(Icons.email),
                  hintText: 'Email',
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 5)),
                )),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
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
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: SizedBox(
                width: double.infinity, // <-- match_parent
                child: ElevatedButton(
                  child: Text('Submit'),
                  onPressed: () => {
                    if (textControllerEmail.text != "" &&
                        textControllerPass1.text != "")
                      {
                        AuthenticationHelper()
                            .signIn(textControllerEmail.text,
                                textControllerPass1.text)
                            .then((result) {
                          if (result == null) {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "Logged in successfully",
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
                        if (textControllerEmail.text == "")
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
                      }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(fontSize: 20)),
                )),
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextButton(
                onPressed: () => {
                  if (textControllerEmail.text != "")
                    {
                      AuthenticationHelper()
                          .forgottenPassword(textControllerEmail.text)
                          .then((result) => {
                                if (result != null)
                                  {
                                    Fluttertoast.showToast(
                                      msg: result,
                                    )
                                  }
                                else
                                  {
                                    Fluttertoast.showToast(
                                      msg: "Reset link sent to email address",
                                    )
                                  }
                              })
                    }
                  else
                    {
                      Fluttertoast.showToast(
                        msg: "Must enter email address",
                      )
                    }
                },
                child: Text('Forgotten password'),
              )),
        ],
      ),
    );
  }
}
