import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/locale_keys.g.dart';
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      minimum: const EdgeInsets.all(32.0),
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
                                  LocaleKeys.logInToGetStarted.tr(),
                                  style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 32.0),
                                  child: GoogleSignInButton(
                                    loading: viewModel.googleLoading,
                                    onPressed: () {
                                      viewModel.signInWithGoogle(context).onError((error, stackTrace) {
                                        final snackBar = SnackBar(
                                          backgroundColor: Colors.red,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16.0),
                                              topRight: Radius.circular(16.0),
                                            ),
                                          ),
                                          content: Text(
                                            viewModel.error!.tr(),
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
                                      viewModel.signInWithApple(context).onError((error, stackTrace) {
                                        final snackBar = SnackBar(
                                          backgroundColor: Colors.red,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16.0),
                                              topRight: Radius.circular(16.0),
                                            ),
                                          ),
                                          content: Text(
                                            viewModel.error!.tr(),
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
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white, fontSize: 16.0),
                                      text: '${LocaleKeys.byLoggingInYouAgreeToOur.tr()} ',
                                    ),
                                    TextSpan(
                                      style: Theme.of(context).textTheme.headline4!.copyWith(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            decoration: TextDecoration.underline,
                                          ),
                                      text: LocaleKeys.privacyPolicy.tr(),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launch('https://walue.app/privacy-policy.pdf');
                                        },
                                    ),
                                    TextSpan(
                                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white, fontSize: 16.0),
                                      text: ' ${LocaleKeys.and.tr()} ',
                                    ),
                                    TextSpan(
                                      style: Theme.of(context).textTheme.headline4!.copyWith(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            decoration: TextDecoration.underline,
                                          ),
                                      text: LocaleKeys.termsAndConditions.tr(),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launch('https://walue.app/terms-and-conditions.pdf');
                                        },
                                    ),
                                    TextSpan(
                                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white, fontSize: 16.0),
                                      text: '.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
