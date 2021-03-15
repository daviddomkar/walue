import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatelessWidget {
  final bool small;

  const Logo({Key? key, this.small = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Walue',
      style: GoogleFonts.fredokaOne(
        textStyle: small ? Theme.of(context).textTheme.headline3 : Theme.of(context).textTheme.headline2,
        color: Colors.white,
      ),
    );
  }
}
