import "package:circles_app/circles_localization.dart";
import "package:circles_app/domain/redux/app_state.dart";
import "package:circles_app/domain/redux/authentication/auth_actions.dart";
import "package:circles_app/presentation/login/auth_button.dart";
import "package:circles_app/util/logger.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_redux/flutter_redux.dart";

String userOldPassword = "";

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("NHIS Message App", style: TextStyle(color: Colors.black)),
              Padding(
                padding: EdgeInsets.all(40.0),
                child: _LoginForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MARK: Login Form

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() {
    return _LoginFormState();
  }
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _userTextEditingController = TextEditingController();
  final _passwordTextEditingController = TextEditingController();
  final _documentIDTextEditingController = TextEditingController();
  Firestore db = Firestore.instance;
  String documentID = "";

  Future silentLogIn({String email, String password}) async {
    //
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final userID = user.uid;
    // print(userID);
    return userID;
  }

  @override
  void dispose() {
    // Suggested to be disposed: https://flutter.dev/docs/cookbook/forms/retrieve-input#1-create-a-texteditingcontroller
    _userTextEditingController.dispose();
    // _passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitCallback = () {
      if (_formKey.currentState.validate()) {
        silentLogIn(
                email: _userTextEditingController.text,
                password: _passwordTextEditingController.text)
            .then((value) {
          db.collection("users").document(value).get().then((res) {
            setState(() {
              documentID = res.data["documentID"];
            });
            if (documentID == _documentIDTextEditingController.text) {
              final loginAction = LogIn(
                  email: _userTextEditingController.text,
                  password: _passwordTextEditingController.text);
              userOldPassword = _passwordTextEditingController.text;
              print(userOldPassword);
              StoreProvider.of<AppState>(context).dispatch(loginAction);
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("Logging you in...")));

              loginAction.completer.future.catchError((error) {
                Scaffold.of(context).hideCurrentSnackBar();
                Logger.w(error.code.toString());
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      CirclesLocalizations.of(context).authErrorMessage(
                        error.code.toString(),
                      ),
                    ),
                  ),
                );
              });

              print(documentID);
            } else {
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text("Incorrect Document ID"),
                ),
              );

              print("no match");
            }
            // print(' admin? ${res.data["admin"]}');
          });
        });
      }
    };

    final submitButton =
        AuthButton(buttonText: "Login", onPressedCallback: submitCallback);

    final _userTextField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: "Email"),
      controller: _userTextEditingController,
      validator: (value) {
        if (value.isEmpty) {
          return "Please enter your email";
        }
        return null;
      },
    );
    final _documentIDTextField = TextFormField(
      decoration: const InputDecoration(labelText: "Document ID"),
      controller: _documentIDTextEditingController,
      validator: (value) {
        if (value.isEmpty) {
          return "Please enter your Document ID";
        }
        return null;
      },
      obscureText: false,
    );
    final _passwordTextField = TextFormField(
      decoration: const InputDecoration(labelText: "Password"),
      controller: _passwordTextEditingController,
      validator: (value) {
        if (value.isEmpty) {
          return "Please enter your password";
        }
        return null;
      },
      obscureText: true,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _userTextField,
          _documentIDTextField,
          _passwordTextField,
          submitButton
        ],
      ),
    );
  }
}
