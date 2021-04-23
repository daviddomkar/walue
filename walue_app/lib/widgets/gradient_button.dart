import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;
  final Widget child;

  const GradientButton(
      {Key? key,
      this.loading = false,
      required this.onPressed,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(16.0),
        ),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          foregroundColor:
              MaterialStateProperty.resolveWith((states) => Colors.white),
          overlayColor: MaterialStateProperty.resolveWith(
              (states) => const Color(0x16000000)),
          padding: MaterialStateProperty.resolveWith((states) =>
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
          shape: MaterialStateProperty.resolveWith(
            (states) => const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
            ),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF222222)),
                      strokeWidth: 2.0,
                    ),
                  ),
                )
              : child,
        ),
      ),
    );
  }
}
