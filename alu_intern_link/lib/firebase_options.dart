// PLACEHOLDER FILE.
//
// Run `flutterfire configure` from the project root (after `firebase login`)
// to replace this file with your real project's generated values. It will
// overwrite this exact file, at this exact path, automatically.
//
// coverage:ignore-file
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured yet. '
        'Run `flutterfire configure` to generate this file for real.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured yet. '
          'Run `flutterfire configure` to generate this file for real.',
        );
    }
  }
}
