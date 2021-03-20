import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency.dart';
import '../models/user.dart';
import '../providers/user_stream_provider.dart';
import '../utils/resource.dart';

final userRepositoryProvider = ChangeNotifierProvider<UserRepository>((ref) => FirebaseUserRepository(userStream: ref.watch(userStreamProvider.stream)));

abstract class UserRepository extends ChangeNotifier {
  Future<void> chooseFiatCurrency(Currency currency);

  Resource<User, String> get user;
}

class FirebaseUserRepository extends UserRepository {
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
  Future<void> chooseFiatCurrency(Currency currency) async {}

  @override
  void dispose() {
    super.dispose();

    _subscription.cancel();
  }

  @override
  Resource<User, String> get user => _user;
}
