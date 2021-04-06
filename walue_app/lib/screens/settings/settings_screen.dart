import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/auth_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final authRepository = watch(authRepositoryProvider);

    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            authRepository.signOut();
          },
          child: Text('Sign out'),
        ),
      ),
    );
  }
}
