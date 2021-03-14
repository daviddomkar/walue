import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'splash_page.dart';

class SplashLocation extends BeamLocation {
  @override
  List<BeamPage> pagesBuilder(BuildContext? context) => [
        BeamPage(
          key: ValueKey('loading'),
          child: SplashPage(),
        ),
      ];

  @override
  List<String> get pathBlueprints => ['/'];
}
