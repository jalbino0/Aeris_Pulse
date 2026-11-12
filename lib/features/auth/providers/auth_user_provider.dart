import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authUserIdProvider = StreamProvider<String?>((ref) {
  try {
    return FirebaseAuth.instance
        .authStateChanges()
        .map((user) => user?.uid)
        .distinct();
  } on FirebaseException catch (error) {
    if (error.code == 'no-app') {
      return Stream<String?>.value(null);
    }

    rethrow;
  }
});
