import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../generated/locale_keys.g.dart';

import 'guide_view_model.dart';

final _guideViewModelProvider = ChangeNotifierProvider.autoDispose((ref) => GuideViewModel(ref.read));

class GuideScreen extends ConsumerWidget {
  const GuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final viewModel = watch(_guideViewModelProvider);

    final dotsDecorator = DotsDecorator(
      color: Colors.white,
      activeColor: Colors.white,
      activeSize: const Size(18.0, 9.0),
      activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: IntroductionScreen(
          curve: Curves.easeInOutCubicEmphasized,
          controlsPadding: const EdgeInsets.all(32.0),
          animationDuration: 250,
          globalBackgroundColor: Colors.transparent,
          scrollPhysics: const PageScrollPhysics(),
          showSkipButton: true,
          dotsDecorator: dotsDecorator,
          next: const Icon(Icons.arrow_forward, color: Colors.white),
          nextColor: Colors.white,
          dotsFlex: 2,
          skip: viewModel.loading
              ? const Center(
                  child: SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.0,
                    ),
                  ),
                )
              : Text(
                  LocaleKeys.skip.tr(),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white, fontSize: 16.0),
                ),
          skipColor: Colors.white,
          done: viewModel.loading
              ? const Center(
                  child: SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.0,
                    ),
                  ),
                )
              : Text(
                  LocaleKeys.done.tr(),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white, fontSize: 16.0),
                ),
          doneColor: Colors.white,
          onSkip: () {
            if (!viewModel.hasCompletedGuide) {
              viewModel.completeGuide();
            } else {
              context.beamBack();
            }
          },
          onDone: () {
            if (!viewModel.hasCompletedGuide) {
              viewModel.completeGuide();
            } else {
              context.beamBack();
            }
          },
          rawPages: const [
            GuideScreenPage(
              title: 'Adding crypto currencies',
              description:
                  'To add a crypto currency to your portfolio, click "Add new crypto" button and search for your currency using the search bar at the top of the opened dialog.\n\nOnce you have added your crypto by tapping on it the currency detail screen will be opened where you can add buy records.',
            ),
            GuideScreenPage(
              title: 'Adding buy records',
              description:
                  'Click "Add new buy record" button on the currency detail screen and enter the buy price and the amount of the currency you bought.\n\n When you click "Add buy record" the buy record will be created. You can add as many buy records as you want.\n\nYou can also edit or delete a buy record by tapping on it.',
            ),
            GuideScreenPage(
              title: 'Favourite cryptocurrencies',
              description:
                  'You can add a crypto to your favourites using the star icon on the currency detail screen or by tapping the "Add favourite" button on the home screen.\n\nAll your favourite cryptocurrencies can be viewed at the top section of the home screen.\n\nTo remove a cryptocurrency from favourites simply click the star icon again on the currency detail page.',
            ),
            GuideScreenPage(
              title: 'App settings',
              description:
                  'App\'s color theme, display language and the default fiat currency can be changed in settings.\n\nYou can get to settings by tapping the icon on the home screen.\n\nApart other things you are also able to delete your account from the setting\'s "Danger zone" section.',
            ),
          ],
        ),
      ),
    );
  }
}

class GuideScreenPage extends StatelessWidget {
  final String title;
  final String description;

  const GuideScreenPage({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 64.0 + 16.0),
      child: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height: 256.0 + 64.0,
                            child: AspectRatio(
                              aspectRatio: 9 / 18.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 32.0),
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 32.0),
                              child: Text(
                                description,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white, fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
