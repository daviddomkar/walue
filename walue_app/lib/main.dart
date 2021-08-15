import 'package:beamer/beamer.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locations.dart';
import 'providers.dart';
import 'repositories/crypto_repository.dart';
import 'repositories/fiat_repository.dart';
import 'utils/no_glow_scroll_behavior.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _licenceFonts();

  await _initFirebase();

  final databaseDirectory = await getApplicationSupportDirectory();

  final cacheStore = HiveCacheStore(databaseDirectory.path);

  if (kDebugMode) {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(false);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        themeProvider.overrideWithValue(ThemeNotifier(sharedPreferences: sharedPreferences)),
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

class WalueApp extends HookWidget {
  final routerDelegate = BeamerDelegate(
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
        RootLocation(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final themeMode = useProvider(themeProvider);
    final theme = ThemeData();

    return MaterialApp.router(
      themeMode: themeMode,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
      theme: theme.copyWith(
        brightness: Brightness.light,
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
        colorScheme: theme.colorScheme.copyWith(
          primary: const Color(0xFF0054F6),
          secondary: const Color(0xFF00D1FF),
        ),
      ),
      darkTheme: theme.copyWith(
        brightness: Brightness.dark,
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
        colorScheme: theme.colorScheme.copyWith(
          primary: const Color(0xFF0054F6),
          secondary: const Color(0xFF00D1FF),
        ),
      ),
    );
  }
}
