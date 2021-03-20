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
        }));
});
