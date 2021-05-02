import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final bool small;
  final Color color;

  const Logo({Key? key, this.small = false, this.color = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Walue',
      style: (small ? Theme.of(context).textTheme.headline3! : Theme.of(context).textTheme.headline2!).copyWith(
        color: color,
      ),
      textAlign: TextAlign.center,
    );
  }
}
