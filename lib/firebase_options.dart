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
    apiKey: 'AIzaSyAq2BSqZseD0R8MyLKHsQbiorowyrMFo20',
    appId: '1:996311847975:web:32582155a18f3c9205aa02',
    messagingSenderId: '996311847975',
    projectId: 'homegrown-4ade0',
    authDomain: 'homegrown-4ade0.firebaseapp.com',
    storageBucket: 'homegrown-4ade0.appspot.com',
    measurementId: 'G-BFB9C0Q30C',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCbxwI_7zTYjsGVXOBd0TNFTOQRvDH5Mwo',
    appId: '1:996311847975:android:fd1c28cd33177a5f05aa02',
    messagingSenderId: '996311847975',
    projectId: 'homegrown-4ade0',
    storageBucket: 'homegrown-4ade0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAkjH4PAoLRcRHc5SKRy9PA-NaU-hqjko0',
    appId: '1:996311847975:ios:9cc20c98ff9940a705aa02',
    messagingSenderId: '996311847975',
    projectId: 'homegrown-4ade0',
    storageBucket: 'homegrown-4ade0.appspot.com',
    iosClientId: '996311847975-5ii4qon8mleaqorf5klqc2vq7n53mk5l.apps.googleusercontent.com',
    iosBundleId: 'com.example.homeGrown',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAkjH4PAoLRcRHc5SKRy9PA-NaU-hqjko0',
    appId: '1:996311847975:ios:9cc20c98ff9940a705aa02',
    messagingSenderId: '996311847975',
    projectId: 'homegrown-4ade0',
    storageBucket: 'homegrown-4ade0.appspot.com',
    iosClientId: '996311847975-5ii4qon8mleaqorf5klqc2vq7n53mk5l.apps.googleusercontent.com',
    iosBundleId: 'com.example.homeGrown',
  );
}
