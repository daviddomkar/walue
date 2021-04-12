import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/auth_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final authRepository = watch(authRepositoryProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: TextButton(
          onPressed: () {
            authRepository.signOut();
          },
          child: const Text('Sign out'),
        ),
      ),
    );
  }
}
