import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:walue_app/providers.dart';

import '../../widgets/logo.dart';

class SplashScreen extends HookWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );

    final fadeInAnimation = useAnimation(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));

    final test = useProvider(testProvider);

    useEffect(() {
      animationController.forward();

      Future.delayed(const Duration(seconds: 1)).then((_) {
        test.state = true;
      });
    }, []);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
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
        child: Center(
          child: Opacity(
            opacity: fadeInAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Logo(),
                const Padding(
                  padding: EdgeInsets.only(top: 32.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
