import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => FirebaseAuthRepository());

abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signOut();
}

class FirebaseAuthRepository extends AuthRepository {
  final _auth = FirebaseAuth.instance;

  @override
  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } else {
      throw 'Could not sign in!';
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
