import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stream_transform/stream_transform.dart';

import '../models/currency.dart';
import '../models/user.dart';

import '../utils/resource.dart';

final authRepositoryProvider = ChangeNotifierProvider<AuthRepository>((ref) => FirebaseAuthRepository());

abstract class AuthRepository extends ChangeNotifier {
  Resource<User?, dynamic> get user;
}

class FirebaseAuthRepository extends AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Resource<User?, dynamic> _user;

  late StreamSubscription _subscription;

  FirebaseAuthRepository() : _user = const Resource.empty() {
    _subscription = _auth
        .idTokenChanges()
        .switchMap((user) => user == null
            ? Stream.value(null)
            : _firestore.collection('users').doc(user.uid).snapshots().map((snapshot) {
                return snapshot.exists
                    ? User(
                        email: user.email!,
                        displayName: user.displayName!,
                        fiatCurrency: Currency(
                          symbol: snapshot.data()!['currency']['symbol'] as String,
                          name: snapshot.data()!['currency']['name'] as String,
                        ),
                      )
                    : User(
                        email: user.email!,
                        displayName: user.displayName!,
                      );
              }))
        .listen((event) {
      _user = Resource.withData(event);
      notifyListeners();
    }, onError: (error) {
      _user = Resource.withError(error);
      notifyListeners();
    });
  }

  @override
  Resource<User?, dynamic> get user => _user;

  @override
  void dispose() {
    super.dispose();

    _subscription.cancel();
  }
}
