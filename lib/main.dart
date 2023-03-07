import 'package:flutter/material.dart';
import 'package:tripo/authentication.dart';
import 'package:tripo/utils/styles.dart';
import 'package:tripo/view_models/view_models.dart';
import 'package:tripo/views/onboarding.dart';
import 'package:tripo/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ViewModel())],
      child: MaterialApp(
        title: 'Tripo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'DMSans',
          primaryColor: Styles.primaryColor,
          backgroundColor: Styles.primaryColor,
        ),
        initialRoute: '/authentication',
        routes: <String, WidgetBuilder>{
          '/authentication': (BuildContext context) => const Authentication(),
          '/onboarding': (BuildContext context) => const Onboarding(),
          '/home': (BuildContext context) => const BottomNav(),
          '/login': (BuildContext context) => const LoginPage(),
        },
      ),
    );
  }
}
