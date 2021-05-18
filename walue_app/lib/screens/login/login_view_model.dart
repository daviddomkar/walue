import 'package:flutter/foundation.dart';

import '../../repositories/auth_repository.dart';

class LogInViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  bool _googleLoading;
  bool _appleLoading;
  String? _error;

  LogInViewModel({required this.authRepository})
      : _googleLoading = false,
        _appleLoading = false;

  Future<void> signInWithGoogle() async {
    _googleLoading = true;
    notifyListeners();

    try {
      await authRepository.signInWithGoogle();
    } catch (error) {
      _error = 'Could not sign in with Google';
      _googleLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    _appleLoading = true;
    notifyListeners();

    try {
      await authRepository.signInWithApple();
    } catch (error) {
      _error = 'Could not sign in with Apple';
      _appleLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  bool get googleLoading => _googleLoading;
  bool get appleLoading => _appleLoading;

  String? get error => _error;
}
