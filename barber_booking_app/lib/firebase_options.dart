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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCFFzbmCRjtGWszRpDZj_0vFOzAr5a4z6U',
    appId: '1:684280807149:web:2773a08b9d54a2301956e4',
    messagingSenderId: '684280807149',
    projectId: 'barberbooking-5d82f',
    authDomain: 'barberbooking-5d82f.firebaseapp.com',
    storageBucket: 'barberbooking-5d82f.firebasestorage.app',
    measurementId: 'G-DW0SB6T6PE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgz_DXIfIMdgSzurbSMwxsVZRkcaw7rSk',
    appId: '1:684280807149:android:1fe68027316083c41956e4',
    messagingSenderId: '684280807149',
    projectId: 'barberbooking-5d82f',
    storageBucket: 'barberbooking-5d82f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA69bKVthP7rjkJXghiyEizgFCJdplnUxM',
    appId: '1:684280807149:ios:fb00bd1358b09d2b1956e4',
    messagingSenderId: '684280807149',
    projectId: 'barberbooking-5d82f',
    storageBucket: 'barberbooking-5d82f.firebasestorage.app',
    iosBundleId: 'com.example.barberBookingApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA69bKVthP7rjkJXghiyEizgFCJdplnUxM',
    appId: '1:684280807149:ios:fb00bd1358b09d2b1956e4',
    messagingSenderId: '684280807149',
    projectId: 'barberbooking-5d82f',
    storageBucket: 'barberbooking-5d82f.firebasestorage.app',
    iosBundleId: 'com.example.barberBookingApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCFFzbmCRjtGWszRpDZj_0vFOzAr5a4z6U',
    appId: '1:684280807149:web:1e3374870a67f86d1956e4',
    messagingSenderId: '684280807149',
    projectId: 'barberbooking-5d82f',
    authDomain: 'barberbooking-5d82f.firebaseapp.com',
    storageBucket: 'barberbooking-5d82f.firebasestorage.app',
    measurementId: 'G-8611DVCBS9',
  );
}
