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

    const bodyStyle = TextStyle(fontSize: 19.0);

    final dotsDecorator = DotsDecorator(
      color: Colors.white,
      activeColor: Colors.white,
      activeSize: const Size(18.0, 9.0),
      activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    );

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
      bodyFlex: 2,
      imageFlex: 3,
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
          pages: [
            PageViewModel(
              title: "Add crypto currency",
              body: "Instead of having to buy an entire share, invest any amount you want.",
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Add buy record",
              body: "Download the Stockpile app and master the market with our mini-lesson.",
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Favourites",
              body: "Kids and teens can track their stocks 24/7 and place trades that you approve.",
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Settings",
              body: "Pages can be full screen as well.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id euismod lectus, non tempor felis. Nam rutrum rhoncus est ac venenatis.",
            ),
          ],
        ),
      ),
    );
  }
}
