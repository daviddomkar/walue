import 'package:flutter/material.dart';

class BasicButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;
  final Widget child;

  final Color? foregroundColor;
  final Color? backgroundColor;

  const BasicButton({Key? key, this.loading = false, required this.onPressed, required this.child, this.foregroundColor, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith((states) => foregroundColor ?? const Color(0xFF222222)),
        backgroundColor: MaterialStateProperty.resolveWith((states) => backgroundColor ?? Colors.white),
        overlayColor: MaterialStateProperty.resolveWith((states) => const Color(0x16000000)),
        padding: MaterialStateProperty.resolveWith((states) => const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
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
            ? Center(
                child: SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor ?? const Color(0xFF222222)),
                    strokeWidth: 2.0,
                  ),
                ),
              )
            : Center(
                child: child,
              ),
      ),
    );
  }
}
