import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/logo.dart';

class ChooseFiatCurrencyScreen extends ConsumerWidget {
  const ChooseFiatCurrencyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Logo(
              small: true,
            ),
            Text(
              'Choose your fiat currency',
              style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
