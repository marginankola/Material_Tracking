import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAswDu-Hx7eh1NDwEVfplHR74i2EFL1tEE',
    appId: '1:236184901337:web:47e5f1c8a9b905d1e3d0c8',
    messagingSenderId: '236184901337',
    projectId: 'materialtrackingapp-b0710',
    authDomain: 'materialtrackingapp-b0710.firebaseapp.com',
    storageBucket: 'materialtrackingapp-b0710.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAswDu-Hx7eh1NDwEVfplHR74i2EFL1tEE',
    appId: '1:236184901337:android:47e5f1c8a9b905d1e3d0c8',
    messagingSenderId: '236184901337',
    projectId: 'materialtrackingapp-b0710',
    storageBucket: 'materialtrackingapp-b0710.firebasestorage.app',
    androidClientId:
        '236184901337-47e5f1c8a9b905d1e3d0c8.apps.googleusercontent.com',
  );
}
