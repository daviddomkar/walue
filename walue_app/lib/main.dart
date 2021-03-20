import 'package:beamer/beamer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walue_app/locations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  _licenceFonts();

  await _initFirebase();

  runApp(
    ProviderScope(
      child: WalueApp(),
    ),
  );
}

Future<void> _initFirebase() async {
  await Firebase.initializeApp();
}

void _licenceFonts() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL-Lato.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL-FredokaOne.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}

class WalueApp extends StatelessWidget {
  final routerDelegate = BeamerRouterDelegate(
    beamLocations: [
      HomeLocation(),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerRouteInformationParser(),
      backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme().copyWith(
          headline2: GoogleFonts.fredokaOne(fontSize: 64.0),
          headline3: GoogleFonts.fredokaOne(fontSize: 48.0),
          headline5: GoogleFonts.lato(fontSize: 24.0, fontWeight: FontWeight.w300),
        ),
        primaryColor: const Color(0xFF0054F6),
        accentColor: const Color(0xFF00D1FF),
      ),
    );
  }
}
