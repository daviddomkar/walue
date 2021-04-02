import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_transform/stream_transform.dart';

import '../models/currency.dart';
import '../models/user.dart';

final userStreamProvider = StreamProvider<User?>((ref) {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  return _auth.idTokenChanges().switchMap((user) => user == null
      ? Stream.value(null)
      : _firestore.collection('users').doc(user.uid).snapshots().map((snapshot) {
          return snapshot.exists
              ? User(
                  id: user.uid,
                  email: user.email!,
                  displayName: user.displayName!,
                  fiatCurrency: Currency(
                    symbol: snapshot.data()!['fiat_currency']['symbol'] as String,
                    name: snapshot.data()!['fiat_currency']['name'] as String,
                  ),
                )
              : User(
                  id: user.uid,
                  email: user.email!,
                  displayName: user.displayName!,
                );
        }));
});
