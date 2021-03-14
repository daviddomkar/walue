import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  _licenceFonts();

  runApp(MyApp());
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

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: Scaffold(
        body: Center(
          child: Text('Flutter Demo Home Page'),
        ),
      ),
    );
  }
}
