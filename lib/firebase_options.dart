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
    apiKey: 'AIzaSyBrE7mOUZzMgkxjhtNHTXqiqA_ITysYs4A',
    appId: '1:1019798704291:web:184bfb5ceef1606f492f16',
    messagingSenderId: '1019798704291',
    projectId: 'tireiqv-2',
    authDomain: 'tireiqv-2.firebaseapp.com',
    storageBucket: 'tireiqv-2.appspot.com',
    measurementId: 'G-8JCYZHR7W4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDeFdcgd36i6Mto7l1xX5zVSqQPQhrC3x0',
    appId: '1:1019798704291:android:3c348cd9fd14a4c3492f16',
    messagingSenderId: '1019798704291',
    projectId: 'tireiqv-2',
    storageBucket: 'tireiqv-2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADCJxtKGunh8sc_FzqrGV64phFbLUKsgk',
    appId: '1:1019798704291:ios:f0e83583f84f259c492f16',
    messagingSenderId: '1019798704291',
    projectId: 'tireiqv-2',
    storageBucket: 'tireiqv-2.appspot.com',
    iosClientId: '1019798704291-5nbv785t90bn1ci02pr26jg7phrl7iok.apps.googleusercontent.com',
    iosBundleId: 'com.example.tireiqVersionii',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyADCJxtKGunh8sc_FzqrGV64phFbLUKsgk',
    appId: '1:1019798704291:ios:f0e83583f84f259c492f16',
    messagingSenderId: '1019798704291',
    projectId: 'tireiqv-2',
    storageBucket: 'tireiqv-2.appspot.com',
    iosClientId: '1019798704291-5nbv785t90bn1ci02pr26jg7phrl7iok.apps.googleusercontent.com',
    iosBundleId: 'com.example.tireiqVersionii',
  );
}
