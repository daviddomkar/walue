import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walue_app/repositories/auth_repository.dart';
import 'package:beamer/beamer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            context.read(authRepositoryProvider).signOut();
          },
          child: ElevatedButton(
            onPressed: () {
              context.beamToNamed('/currency/bitcoin');
            },
            child: Text('bitcoin'),
          ),
        ),
      ),
    );
  }
}
