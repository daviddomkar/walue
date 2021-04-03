import 'package:flutter/foundation.dart';

import '../../repositories/auth_repository.dart';

class LogInViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  bool _loading;
  String? _error;

  LogInViewModel({required this.authRepository}) : _loading = false;

  Future<void> continueWithGoogle() async {
    _loading = true;
    notifyListeners();

    try {
      await authRepository.signInWithGoogle();
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
