import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final bool small;

  const Logo({Key? key, this.small = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Walue',
      style: (small
              ? Theme.of(context).textTheme.headline3!
              : Theme.of(context).textTheme.headline2!)
          .copyWith(
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }
}
