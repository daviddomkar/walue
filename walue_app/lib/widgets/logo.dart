import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Walue',
      style: GoogleFonts.fredokaOne(
        textStyle: Theme.of(context).textTheme.headline2,
        color: Colors.white,
      ),
    );
  }
}
