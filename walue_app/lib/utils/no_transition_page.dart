import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class NoTransitionPage extends BeamPage {
  @override
  final Widget child;

  NoTransitionPage({
    Key? key,
    String? name,
    required this.child,
    bool keepQueryOnPop = false,
  }) : super(key: key, name: name, child: child, keepQueryOnPop: keepQueryOnPop);

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
    );
  }
}
