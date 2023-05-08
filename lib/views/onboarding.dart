import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tripo/generated/assets.dart';
import 'package:tripo/widgets/bottom_nav.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const BottomNav(),
        ),
      );
    }

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          return Scaffold(
              body: Stack(children: <Widget>[
            Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(Assets.background),
                        fit: BoxFit.cover))),
            Padding(
              padding: const EdgeInsets.only(
                  top: 73, left: 32, right: 32, bottom: 190),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        // Padding(
                        //   padding: EdgeInsets.only(right: 48.0),
                        //   child: Text.rich(TextSpan(
                        //     text: '',
                        //     style: TextStyle(color: Colors.white, fontSize: 58),
                        //   )),
                        // ),
                        // Padding(
                        //   padding: EdgeInsets.only(bottom: 55),
                        //   child: Text(
                        //       'Some text here some text here some text here some text here some text here',
                        //       textAlign: TextAlign.center,
                        //       style: TextStyle(
                        //           color: Color.fromARGB(255, 158, 158, 158),
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.w200)),
                        // ),
                      ],
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 42.0),
                    //   child: Row(children: <Widget>[
                    //     Image.asset(Assets.appLogo, scale: 2.6),
                    //     const SizedBox(width: 30.0),
                    //     Image.asset(Assets.androidLogo, scale: 2.6)
                    //   ]),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: TextButton(
                            // textColor: Colors.white,
                            // color: const Color(0xFFF69A26),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/authentication');
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF69A26),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16.0),
                              textStyle: const TextStyle(fontSize: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text('Get Started!',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 18.0))),
                      ),
                    )
                  ],
                ),
              ),
            )
          ]));
        });
  }
}
