import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/auth_repository.dart';
import '../../widgets/apple_sign_in_button.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../widgets/logo.dart';
import 'login_view_model.dart';

final logInViewModelProvider = ChangeNotifierProvider.autoDispose<LogInViewModel>(
  (ref) => LogInViewModel(authRepository: ref.watch(authRepositoryProvider)),
);

class LogInScreen extends ConsumerWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final viewModel = watch(logInViewModelProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                    children: [
                      const SizedBox(
                        height: 80.0,
                      ),
                      Expanded(
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
                                loading: viewModel.googleLoading,
                                onPressed: () {
                                  viewModel.signInWithGoogle().onError((error, stackTrace) {
                                    final snackBar = SnackBar(
                                      backgroundColor: Colors.red,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16.0),
                                          topRight: Radius.circular(16.0),
                                        ),
                                      ),
                                      content: Text(
                                        viewModel.error!,
                                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                              fontSize: 16.0,
                                              color: Colors.white,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: AppleSignInButton(
                                loading: viewModel.appleLoading,
                                onPressed: () {
                                  viewModel.signInWithApple().onError((error, stackTrace) {
                                    final snackBar = SnackBar(
                                      backgroundColor: Colors.red,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16.0),
                                          topRight: Radius.circular(16.0),
                                        ),
                                      ),
                                      content: Text(
                                        viewModel.error!,
                                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                              fontSize: 16.0,
                                              color: Colors.white,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 80.0,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white, fontSize: 18.0),
                                    text: 'By logging in, you agree to our ',
                                  ),
                                  TextSpan(
                                    style: Theme.of(context).textTheme.headline4!.copyWith(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          decoration: TextDecoration.underline,
                                        ),
                                    text: 'Privacy Policy',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // TODO: Visit privacy policy
                                      },
                                  ),
                                  TextSpan(
                                    style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white, fontSize: 18.0),
                                    text: ' and ',
                                  ),
                                  TextSpan(
                                    style: Theme.of(context).textTheme.headline4!.copyWith(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          decoration: TextDecoration.underline,
                                        ),
                                    text: 'Terms of Service',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // TODO: Visit terms of service
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
