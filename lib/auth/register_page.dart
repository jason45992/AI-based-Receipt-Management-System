import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripo/auth/fire_auth.dart';
import 'package:tripo/auth/validator.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/widgets/buttons.dart';
import 'package:tripo/widgets/my_app_bar.dart';

import '../utils/styles.dart';
import '../widgets/bottom_nav.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  final db = FirebaseFirestore.instance;

  bool _isProcessing = false;
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar:
            myAppBar(title: 'Register', implyLeading: true, context: context),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _registerFormKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        autocorrect: false,
                        enableSuggestions: false,
                        controller: _nameTextController,
                        focusNode: _focusName,
                        validator: (value) => Validator.validateName(
                          name: value,
                        ),
                        cursorColor: Styles.primaryColor,
                        decoration: InputDecoration(
                          hintText: 'Name',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Styles.primaryColor),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
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
                            borderSide: BorderSide(color: Styles.primaryColor),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordTextController,
                        focusNode: _focusPassword,
                        obscureText: true,
                        validator: (value) => Validator.validatePassword(
                          password: value,
                        ),
                        cursorColor: Styles.primaryColor,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Styles.primaryColor),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      if (_isError)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            'The account already exists, please try login.',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      _isProcessing
                          ? CircularProgressIndicator(
                              color: Styles.primaryColor,
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: elevatedButton(
                                    // color:
                                    //     Repository.selectedItemColor(context),
                                    context: context,
                                    text: 'Sign up',
                                    callback: () async {
                                      if (_registerFormKey.currentState!
                                          .validate()) {
                                        setState(() {
                                          _isProcessing = true;
                                        });
                                        User? user = await FireAuth
                                            .registerUsingEmailPassword(
                                          name: _nameTextController.text,
                                          email: _emailTextController.text,
                                          password:
                                              _passwordTextController.text,
                                        );

                                        final userInfo = <String, dynamic>{
                                          'name': _nameTextController.text,
                                          'email': _emailTextController.text,
                                          'profile_photo_url': ''
                                        };

                                        db.collection('users').add(userInfo).then(
                                            (DocumentReference doc) => print(
                                                'DocumentSnapshot added with ID: ${doc.id}'));

                                        setState(() {
                                          _isProcessing = false;
                                        });

                                        if (user != null) {
                                          _isError = false;
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const BottomNav(),
                                            ),
                                            ModalRoute.withName('/'),
                                          );
                                        } else {
                                          _isError = true;
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
