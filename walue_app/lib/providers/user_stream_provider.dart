import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_transform/stream_transform.dart';

import '../models/currency.dart';
import '../models/user.dart';

final userStreamProvider = StreamProvider.autoDispose<User?>((ref) {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  return _auth
      .authStateChanges()
      .switchMap((user) => user == null
          ? Stream.value(null)
          : _firestore.collection('users').doc(user.uid).snapshots().map((snapshot) {
              if (snapshot.exists) {
                final data = snapshot.data()!;

                return User(
                  id: user.uid,
                  email: user.email!,
                  displayName: user.displayName == null || user.displayName!.isEmpty ? null : user.displayName,
                  photoUrl: user.photoURL,
                  fiatCurrencySymbol: data.containsKey('fiat_currency_symbol') ? data['fiat_currency_symbol'] as String : null,
                  favouriteCurrencyIds: (data['favourite_currency_ids'] as List<dynamic>?)?.cast<String>() ?? [],
                );
              }

              return User(
                id: user.uid,
                email: user.email!,
                displayName: user.displayName == null || user.displayName!.isEmpty ? null : user.displayName,
                photoUrl: user.photoURL,
              );
            }))
      .handleError((Object e, StackTrace s) {
    FirebaseCrashlytics.instance.recordError(
      e,
      s,
      reason: 'User stream provider error',
    );

    throw e;
  });
});

final uuidStreamProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(userStreamProvider).data?.value?.id;
});

final userFiatCurrencyStreamProvider = StreamProvider.autoDispose<Currency?>((ref) {
  final _firestore = FirebaseFirestore.instance;

  final symbol = ref.watch(userStreamProvider).data?.value?.fiatCurrencySymbol;

  return symbol == null
      ? Stream.value(null)
      : _firestore
          .collection('system')
          .doc('fiat')
          .snapshots()
          .map((snapshot) {
            if (snapshot.exists) {
              final currencies = snapshot.data()!['currencies'] as Map<String, dynamic>;

              return currencies.entries.fold<Map<String, Currency>>({}, (previousValue, element) {
                previousValue[element.key] = Currency(name: element.value as String, symbol: element.key);
                return previousValue;
              });
            }

            throw 'Fiat currency data are not available!';
          })
          .map((currencies) => currencies[symbol] ?? Currency(symbol: symbol, name: symbol))
          .handleError((Object e, StackTrace s) {
            FirebaseCrashlytics.instance.recordError(
              e,
              s,
              reason: 'Fiat currencies stream provider error',
            );

            throw e;
          });
});

final fiatCurrencyStreamProvider = Provider.autoDispose<Currency?>((ref) {
  return ref.watch(userFiatCurrencyStreamProvider).data?.value;
});

final favouriteCurrencyIdsStreamProvider = Provider.autoDispose<List<String>?>((ref) {
  return ref.watch(userStreamProvider).data?.value?.favouriteCurrencyIds;
});
