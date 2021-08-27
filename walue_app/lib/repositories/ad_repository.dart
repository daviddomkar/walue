import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walue_app/generated/ad_ids.g.dart';

final adRepositoryProvider = Provider<AdRepository>((ref) => throw UnimplementedError());

const _newBuyRecordCountToShowAd = 5;
const _newCryptoCurrencyCountToShowAd = 3;
const _lastTimeAppOpenedDurationToShowAd = Duration(hours: 1);

abstract class AdRepository {
  Future<void> notifyNewBuyRecord();
  Future<void> notifyNewCryproCurrency();
  Future<void> notifyAppOpened();
}

class AdmobAdRepository extends AdRepository {
  final SharedPreferences sharedPreferences;

  int _newBuyRecordCount;
  int _newCryptoCurrencyCount;
  DateTime _lastTimeAppOpened;

  InterstitialAd? _interstitialAd;

  AdmobAdRepository({required this.sharedPreferences})
      : _newBuyRecordCount = sharedPreferences.containsKey('new_buy_record_count') ? sharedPreferences.getInt('new_buy_record_count')! : 0,
        _newCryptoCurrencyCount = sharedPreferences.containsKey('new_crypto_currency_count') ? sharedPreferences.getInt('new_crypto_currency_count')! : 0,
        _lastTimeAppOpened = sharedPreferences.containsKey('last_time_app_opened')
            ? DateTime.fromMillisecondsSinceEpoch(sharedPreferences.getInt('last_time_app_opened')!)
            : (() {
                final now = DateTime.now();

                sharedPreferences.setInt('last_time_app_opened', now.millisecondsSinceEpoch);
                return now;
              })() {
    _load();
  }

  @override
  Future<void> notifyNewBuyRecord() async {
    _newBuyRecordCount++;

    if (_newBuyRecordCount >= _newBuyRecordCountToShowAd) {
      try {
        await _showInterstitialAd();
        _newBuyRecordCount = 0;
      } catch (_) {}
    }

    sharedPreferences.setInt('new_buy_record_count', _newBuyRecordCount);
  }

  @override
  Future<void> notifyNewCryproCurrency() async {
    _newCryptoCurrencyCount++;

    if (_newCryptoCurrencyCount >= _newCryptoCurrencyCountToShowAd) {
      try {
        await _showInterstitialAd();
        _newCryptoCurrencyCount = 0;
      } catch (_) {}
    }

    sharedPreferences.setInt('new_crypto_currency_count', _newCryptoCurrencyCount);
  }

  @override
  Future<void> notifyAppOpened() async {
    if (_lastTimeAppOpened.add(_lastTimeAppOpenedDurationToShowAd).isBefore(DateTime.now())) {
      try {
        await _showInterstitialAd();
        _lastTimeAppOpened = DateTime.now();
        sharedPreferences.setInt('last_time_app_opened', _lastTimeAppOpened.millisecondsSinceEpoch);
      } catch (_) {}
    }
  }

  Future<void> _showInterstitialAd() async {
    InterstitialAd ad;

    if (_interstitialAd == null) {
      try {
        ad = await _loadInterstitialAd();
      } catch (e) {
        rethrow;
      }
    } else {
      ad = _interstitialAd!;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _load();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        throw error;
      },
    );

    ad.show();
  }

  Future<void> _load() async {
    try {
      _interstitialAd = await _loadInterstitialAd();
    } catch (e) {
      Timer(const Duration(minutes: 1), () {
        _load();
      });
    }
  }

  Future<InterstitialAd> _loadInterstitialAd() async {
    final completer = Completer<InterstitialAd>();

    await InterstitialAd.load(
      adUnitId: kDebugMode ? InterstitialAd.testAdUnitId : mainInterstitialAd,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          completer.complete(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          completer.completeError(error);
        },
      ),
    );

    return completer.future;
  }
}
