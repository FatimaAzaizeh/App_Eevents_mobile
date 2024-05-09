// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAltiKg2jw46nTkQSYA09FGIzDq9KaF-yQ',
    appId: '1:394890785815:web:7a7604b9f8320e85a8d852',
    messagingSenderId: '394890785815',
    projectId: 'eeventsapp-183f1',
    authDomain: 'eeventsapp-183f1.firebaseapp.com',
    storageBucket: 'eeventsapp-183f1.appspot.com',
    measurementId: 'G-4QFSBPY7Q8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAW2To7lqwmTpnQYh689G9U70fx8C5BCUs',
    appId: '1:394890785815:android:19dae1407ced3f2ba8d852',
    messagingSenderId: '394890785815',
    projectId: 'eeventsapp-183f1',
    storageBucket: 'eeventsapp-183f1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCHojQu4gD9MdYfvoMFp9YvRbWaJAcr0pk',
    appId: '1:394890785815:ios:9e6961c01db955cfa8d852',
    messagingSenderId: '394890785815',
    projectId: 'eeventsapp-183f1',
    storageBucket: 'eeventsapp-183f1.appspot.com',
    androidClientId: '394890785815-o4mfhgatud98k79uprv5irl5td9f1iq7.apps.googleusercontent.com',
    iosClientId: '394890785815-infbvmu27bo4oorlefngherm11k4a9i0.apps.googleusercontent.com',
    iosBundleId: 'com.example.testtapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCHojQu4gD9MdYfvoMFp9YvRbWaJAcr0pk',
    appId: '1:394890785815:ios:f355ee83ee7373aaa8d852',
    messagingSenderId: '394890785815',
    projectId: 'eeventsapp-183f1',
    storageBucket: 'eeventsapp-183f1.appspot.com',
    androidClientId: '394890785815-o4mfhgatud98k79uprv5irl5td9f1iq7.apps.googleusercontent.com',
    iosClientId: '394890785815-g57624lvd4hnvhkblu8b535oa1t1avv6.apps.googleusercontent.com',
    iosBundleId: 'com.example.testtapp.RunnerTests',
  );
}
