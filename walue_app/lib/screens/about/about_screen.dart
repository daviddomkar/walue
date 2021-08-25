import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/locale_keys.g.dart';
import '../../widgets/logo.dart';
import '../settings/settings_screen.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.light ? Brightness.dark : Brightness.light,
        statusBarBrightness: Theme.of(context).brightness,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF000000),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: SafeArea(
                  minimum: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Logo(
                                color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                small: true,
                              ),
                              Transform.translate(
                                offset: const Offset(0.0, -10.0),
                                child: Text(
                                  LocaleKeys.about.tr(),
                                  style: Theme.of(context).textTheme.headline5!.copyWith(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white),
                                ),
                              ),
                            ],
                          ),
                          Transform.translate(
                            offset: const Offset(8.0, 0.0),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                context.beamBack();
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.arrowLeft,
                                color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          height: 48.0,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16.0),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Color(0x32000000),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
                            child: InkWell(
                              onTap: () {
                                context.beamToNamed('/settings/about');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        LocaleKeys.guide.tr(),
                                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                              color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                            ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: FaIcon(
                                    FontAwesomeIcons.bolt,
                                    color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                  ),
                                ),
                                Text(
                                  LocaleKeys.poweredBy.tr(),
                                  style: Theme.of(context).textTheme.headline4!.copyWith(
                                        fontSize: 24.0,
                                        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                      ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 4.0,
                                      color: Color(0x32000000),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    PreferenceItem(
                                      title: 'CoinGecko',
                                      subtitle: LocaleKeys.cryptocurrencyDataAPI.tr(),
                                      value: LocaleKeys.visit.tr(),
                                      onTap: () => launch('https://www.coingecko.com/en/api'),
                                    ),
                                    PreferenceItem(
                                      title: 'ExchangeRate.host',
                                      subtitle: LocaleKeys.fiatCurrencyExchangeAPI.tr(),
                                      value: LocaleKeys.visit.tr(),
                                      onTap: () => launch('https://exchangerate.host/'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
