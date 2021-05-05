import 'package:beamer/beamer.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'locations.dart';
import 'repositories/crypto_repository.dart';
import 'repositories/fiat_repository.dart';
import 'utils/no_glow_scroll_behavior.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  _licenceFonts();

  await _initFirebase();

  final databaseDirectory = await getApplicationSupportDirectory();

  final cacheStore = HiveCacheStore(databaseDirectory.path);

  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  runApp(
    ProviderScope(
      overrides: [
        cryptoRepositoryProvider.overrideWithValue(CoinGeckoCryptoRepository(cacheStore: cacheStore)),
        fiatRepositoryProvider.overrideWithValue(ExchangeRateHostFiatRepository(cacheStore: cacheStore)),
      ],
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
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
        RootLocation(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      routeInformationParser: BeamerRouteInformationParser(),
      routerDelegate: routerDelegate,
      backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme().copyWith(
          headline2: GoogleFonts.fredokaOne(fontSize: 64.0, color: const Color(0xFF222222)),
          headline3: GoogleFonts.fredokaOne(fontSize: 48.0, color: const Color(0xFF222222)),
          headline4: GoogleFonts.lato(fontSize: 36.0, fontWeight: FontWeight.w700, color: const Color(0xFF222222)),
          headline5: GoogleFonts.lato(fontSize: 24.0, fontWeight: FontWeight.w300, color: const Color(0xFF222222)),
          headline6: GoogleFonts.lato(fontWeight: FontWeight.w300, color: const Color(0xFF222222)),
          subtitle1: GoogleFonts.lato(fontSize: 18.0, color: const Color(0xFF222222)),
          subtitle2: GoogleFonts.lato(fontSize: 14.0, fontWeight: FontWeight.w300, color: const Color(0xFF222222)),
          bodyText1: GoogleFonts.lato(fontSize: 14.0, color: const Color(0xFF222222)),
          bodyText2: GoogleFonts.lato(fontSize: 14.0, fontWeight: FontWeight.w300, color: const Color(0x80222222)),
        ),
        primaryColor: const Color(0xFF0054F6),
        accentColor: const Color(0xFF00D1FF),
      ),
    );
  }
}
