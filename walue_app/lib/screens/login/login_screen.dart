import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/auth_repository.dart';

import '../../widgets/google_sign_in_button.dart';
import '../../widgets/logo.dart';

import 'login_view_model.dart';

final logInViewModelProvider = ChangeNotifierProvider<LogInViewModel>(
  (ref) => LogInViewModel(auth: ref.watch(authRepositoryProvider)),
);

class LogInScreen extends ConsumerWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final viewModel = watch(logInViewModelProvider);

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
              'Log in to get started',
              style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: GoogleSignInButton(
                loading: viewModel.loading,
                onPressed: () {
                  viewModel.continueWithGoogle().onError((error, stackTrace) {
                    final snackBar = SnackBar(content: Text(viewModel.error!));

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
