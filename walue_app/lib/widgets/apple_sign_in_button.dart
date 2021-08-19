import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../generated/locale_keys.g.dart';

class AppleSignInButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const AppleSignInButton({Key? key, this.loading = false, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith((states) => Colors.white),
        backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.black),
        overlayColor: MaterialStateProperty.resolveWith((states) => const Color(0x16FFFFFF)),
        padding: MaterialStateProperty.resolveWith((states) => const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
        shape: MaterialStateProperty.resolveWith(
          (states) => const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          const Image(
            image: AssetImage(
              'assets/icons/apple.png',
            ),
            height: 24.0,
            width: 24.0,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: loading
                  ? const Center(
                      child: SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.0,
                        ),
                      ),
                    )
                  : Text(
                      LocaleKeys.singInWithApple.tr(),
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          const SizedBox(
            width: 24.0,
            height: 24.0,
          ),
        ],
      ),
    );
  }
}
