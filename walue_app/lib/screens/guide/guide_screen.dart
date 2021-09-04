import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:video_player/video_player.dart';

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
              : AutoSizeText(
                  LocaleKeys.skip.tr(),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white, fontSize: 16.0),
                  maxLines: 1,
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
              : AutoSizeText(
                  LocaleKeys.done.tr(),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white, fontSize: 16.0),
                  maxLines: 1,
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
          rawPages: [
            GuideScreenPage(
              videoPath: 'assets/guide/add_cryptocurrency.mp4',
              title: LocaleKeys.guideAddCryptoCurrencyTitle.tr(),
              description: LocaleKeys.guideAddCryptoCurrencyDescription.tr(),
            ),
            GuideScreenPage(
              videoPath: 'assets/guide/add_buy_record.mp4',
              title: LocaleKeys.guideAddBuyRecordsTitle.tr(),
              description: LocaleKeys.guideAddBuyRecordsDescription.tr(),
            ),
            GuideScreenPage(
              videoPath: 'assets/guide/favourites.mp4',
              title: LocaleKeys.guideFavouritesTitle.tr(),
              description: LocaleKeys.guideFavouritesDescription.tr(),
            ),
            GuideScreenPage(
              videoPath: 'assets/guide/settings.mp4',
              title: LocaleKeys.guideSettingsTitle.tr(),
              description: LocaleKeys.guideSettingsDescription.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class GuideScreenPage extends StatefulWidget {
  final String videoPath;
  final String title;
  final String description;

  const GuideScreenPage({
    Key? key,
    required this.videoPath,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<GuideScreenPage> createState() => _GuideScreenPageState();
}

class _GuideScreenPageState extends State<GuideScreenPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.videoPath, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

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
                              aspectRatio: 9 / 18,
                              child: Container(
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: AnimatedOpacity(
                                    opacity: _controller.value.isInitialized ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 250),
                                    child: _controller.value.isInitialized ? VideoPlayer(_controller) : null,
                                  ),
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
                                widget.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 32.0),
                              child: Text(
                                widget.description,
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
