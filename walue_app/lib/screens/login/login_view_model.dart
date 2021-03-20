import 'package:flutter/foundation.dart';

import '../../repositories/auth_repository.dart';

class LogInViewModel extends ChangeNotifier {
  final AuthRepository auth;

  bool _loading;
  String? _error;

  LogInViewModel({required this.auth}) : _loading = false;

  Future<void> continueWithGoogle() async {
    _loading = true;
    notifyListeners();

    try {
      await auth.signInWithGoogle();
    } catch (error) {
      _error = 'Could not sign in with Google';
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  bool get loading => _loading;

  String? get error => _error;
}
