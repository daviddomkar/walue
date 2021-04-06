import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_transform/stream_transform.dart';

import '../models/currency.dart';
import '../models/user.dart';

final userStreamProvider = StreamProvider.autoDispose<User?>((ref) {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  return _auth.idTokenChanges().switchMap((user) => user == null
      ? Stream.value(null)
      : _firestore.collection('users').doc(user.uid).snapshots().map((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;

            return User(
              id: user.uid,
              email: user.email!,
              displayName: user.displayName!,
              fiatCurrency: Currency(
                symbol: data['fiat_currency']['symbol'] as String,
                name: data['fiat_currency']['name'] as String,
              ),
              favouriteCurrencyIds: data['favourite_currency_ids'] as List<String>?,
            );
          }

          return User(
            id: user.uid,
            email: user.email!,
            displayName: user.displayName!,
          );
        }));
});
