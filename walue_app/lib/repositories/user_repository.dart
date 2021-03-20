import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walue_app/providers/user_stream_provider.dart';

import '../models/user.dart';
import '../utils/resource.dart';

final userRepositoryProvider = ChangeNotifierProvider<UserRepository>((ref) => UserRepository(userStream: ref.watch(userStreamProvider.stream)));

class UserRepository extends ChangeNotifier {
  Resource<User, String> _user;

  late StreamSubscription _subscription;

  UserRepository({required Stream<User?> userStream}) : _user = const Resource.empty() {
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
  void dispose() {
    super.dispose();

    _subscription.cancel();
  }

  Resource<User, String> get user => _user;
}
