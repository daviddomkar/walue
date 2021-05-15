import 'dart:ui';

import 'package:flutter/material.dart';

class HeaderBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0.0, size.height - 160.0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0.0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class HeaderBackground extends StatelessWidget {
  const HeaderBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HeaderBackgroundClipper(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 256.0 + 128.0,
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
      ),
    );
  }
}
