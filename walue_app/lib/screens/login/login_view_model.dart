import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../generated/locale_keys.g.dart';
import '../../repositories/auth_repository.dart';

class LogInViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  bool _googleLoading;
  bool _appleLoading;
  String? _error;

  LogInViewModel({required this.authRepository})
      : _googleLoading = false,
        _appleLoading = false;

  Future<void> signInWithGoogle(BuildContext context) async {
    _googleLoading = true;
    notifyListeners();

    try {
      await authRepository.signInWithGoogle();
    } catch (error) {
      _error = LocaleKeys.couldNotSignInWithGoogle;
      _googleLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithApple(BuildContext context) async {
    _appleLoading = true;
    notifyListeners();

    try {
      await authRepository.signInWithApple();
    } catch (error) {
      _error = LocaleKeys.couldNotSignInWithApple;
      _appleLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  bool get googleLoading => _googleLoading;
  bool get appleLoading => _appleLoading;

  String? get error => _error;
}
