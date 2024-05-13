import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:testtapp/firebase_options.dart';

import 'package:testtapp/screens/AnimatedTextPage.dart';
import 'package:testtapp/screens/Home_screen.dart';
import 'package:testtapp/screens/Service_screen.dart';

import 'package:testtapp/screens/login_signup.dart';

final _auth = FirebaseAuth.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.setLoggingEnabled(true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => null //Data to be passed to all pages.//
        ,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale("ar"), // Arabic
            const Locale("en"), // English (fallback)
          ],
          locale: const Locale('ar'), // Set Arabic as the default locale
          // Set text direction to RTL
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
          routes: {
            AnimatedTextPage.screenRoute: (context) => AnimatedTextPage(),
            LoginSignupScreen.screenRoute: (context) => LoginSignupScreen(),
            HomeScreen.screenRoute: (context) => HomeScreen(),
            Service.screenRoute: (context) => Service(),
          },
          home: AnimatedTextPage(),
        ));
  }
}
