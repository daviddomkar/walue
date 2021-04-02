import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency.dart';
import '../models/user.dart';
import '../providers.dart';
import '../utils/resource.dart';

final userRepositoryProvider = ChangeNotifierProvider<UserRepository>((ref) => FirebaseUserRepository(userStream: ref.watch(userStreamProvider.stream)));

abstract class UserRepository extends ChangeNotifier {
  Future<void> chooseFiatCurrency(Currency currency);

  Resource<User, String> get user;
}

class FirebaseUserRepository extends UserRepository {
  final _firestore = FirebaseFirestore.instance;

  Resource<User, String> _user;

  late StreamSubscription _subscription;

  FirebaseUserRepository({required Stream<User?> userStream}) : _user = const Resource.empty() {
    _user = const Resource.loading();
    _subscription = userStream.listen((event) {
      if (event != null) {
        _user = Resource.finishWithData(event);
      } else {
        _user = const Resource.finish();
      }
      notifyListeners();
    }, onError: (error) {
      _user = const Resource.finishWithError('Could not load user!');
      notifyListeners();
    });
  }

  @override
  Future<void> chooseFiatCurrency(Currency currency) async {
    await _firestore.collection('users').doc(_user.data?.id).set({
      'fiat_currency': {
        'symbol': currency.symbol,
        'name': currency.name,
      },
    });
  }

  @override
  void dispose() {
    super.dispose();

    _subscription.cancel();
  }

  @override
  Resource<User, String> get user => _user;
}
