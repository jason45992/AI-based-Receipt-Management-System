import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tripo/auth/register_page.dart';
import 'package:tripo/auth/fire_auth.dart';
import 'package:tripo/auth/validator.dart';
import 'package:tripo/utils/styles.dart';
import 'package:tripo/widgets/buttons.dart';
import 'package:tripo/widgets/my_app_bar.dart';

import '../widgets/bottom_nav.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();

  final _focusEmail = FocusNode();

  bool _isProcessing = false;
  bool _isError = false;

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BottomNav()),
      );
      // Navigator.pushReplacementNamed(context, '/home');
    }

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
      },
      child: Scaffold(
        appBar: myAppBar(
            title: 'Reset Password', implyLeading: true, context: context),
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            autocorrect: false,
                            enableSuggestions: false,
                            controller: _emailTextController,
                            focusNode: _focusEmail,
                            validator: (value) => Validator.validateEmail(
                              email: value,
                            ),
                            cursorColor: Styles.primaryColor,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Styles.primaryColor),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 50.0),
                          if (_isError)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Text(
                                'The email is invalid.',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 13),
                              ),
                            ),
                          _isProcessing
                              ? CircularProgressIndicator(
                                  color: Styles.primaryColor,
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: elevatedButton(
                                            context: context,
                                            callback: () async {
                                              _focusEmail.unfocus();

                                              if (_formKey.currentState!
                                                  .validate()) {
                                                setState(() {
                                                  _isProcessing = true;
                                                });

                                                // User? user = await FireAuth
                                                //     .signInUsingEmailPassword(
                                                //   email:
                                                //       _emailTextController.text,
                                                //   password:
                                                //       _passwordTextController
                                                //           .text,
                                                // );

                                                bool status = await FireAuth
                                                    .resetPassword(
                                                        email:
                                                            _emailTextController
                                                                .text);

                                                setState(() {
                                                  _isProcessing = false;
                                                });

                                                if (status) {
                                                  _isError = false;
                                                  Navigator.of(context)
                                                      .restorablePush(
                                                          _dialogSuccessBuilder);
                                                } else {
                                                  _isError = true;
                                                }
                                              }
                                            },
                                            text: 'Reset'))
                                  ],
                                ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  static Route<Object?> _dialogSuccessBuilder(
      BuildContext context, Object? arguments) {
    return CupertinoDialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Email sent successfully'),
          content: const Text(
              'Please follow the reset password link in the email to reset your password.'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
