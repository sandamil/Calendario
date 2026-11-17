import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Identificadores oficiales de prueba de Google. Sustituir al publicar.
class CalendarioAdUnits {
  static const androidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const iosBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const androidInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const iosInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const androidRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const iosRewarded = 'ca-app-pub-3940256099942544/1712485313';

  static String? get banner => _platform(androidBanner, iosBanner);
  static String? get interstitial =>
      _platform(androidInterstitial, iosInterstitial);
  static String? get rewarded => _platform(androidRewarded, iosRewarded);

  static String? _platform(String android, String ios) {
    if (kIsWeb) return null;
    if (defaultTargetPlatform == TargetPlatform.android) return android;
    if (defaultTargetPlatform == TargetPlatform.iOS) return ios;
    return null;
  }
}

class CalendarioAds {
  CalendarioAds._();

  static InterstitialAd? _menuAd;
  static RewardedAd? _rewardedAd;
  static bool _loadingMenu = false;
  static bool _loadingRewarded = false;
  static Completer<InterstitialAd?>? _menuLoadCompleter;
  static Completer<RewardedAd?>? _rewardedLoadCompleter;
  static const _menuVisitsPreferenceKey =
      'ads_menu_visits_since_interstitial_policy_v1';
  static const _freeMenuVisits = 5;

  static Future<InitializationStatus>? _sdkInitialization;
  static Future<bool>? _consentPreparation;
  static final ValueNotifier<bool> _adsAllowed = ValueNotifier(false);

  static ValueListenable<bool> get adsPermission => _adsAllowed;
  static bool get canRequestAds => _adsAllowed.value;

  static Future<InitializationStatus> _initializeSdk() {
    return _sdkInitialization ??= MobileAds.instance.initialize();
  }

  /// Actualiza el consentimiento UMP antes de solicitar anuncios.
  ///
  /// Rechazar la personalización no implica necesariamente rechazar toda
  /// publicidad: UMP determina si se pueden servir anuncios contextuales,
  /// limitados o no personalizados según las opciones legales disponibles.
  static Future<bool> _requestConsent() {
    final completer = Completer<bool>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((error) {
            if (error != null) {
              debugPrint('[ADS][UMP] Formulario: $error');
            }
          });
          final allowed = await ConsentInformation.instance.canRequestAds();
          debugPrint('[ADS][UMP] canRequestAds=$allowed');
          if (!completer.isCompleted) completer.complete(allowed);
        } catch (error, stackTrace) {
          debugPrint('[ADS][UMP] Error mostrando consentimiento: $error');
          debugPrintStack(stackTrace: stackTrace);
          final allowed = await _cachedConsentPermission();
          if (!completer.isCompleted) completer.complete(allowed);
        }
      },
      (error) async {
        debugPrint('[ADS][UMP] No se pudo actualizar consentimiento: $error');
        final allowed = await _cachedConsentPermission();
        if (!completer.isCompleted) completer.complete(allowed);
      },
    );
    return completer.future.timeout(
      const Duration(seconds: 25),
      onTimeout: () async => _cachedConsentPermission(),
    );
  }

  static Future<bool> _cachedConsentPermission() async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (error) {
      debugPrint('[ADS][UMP] No se pudo comprobar permiso: $error');
      return false;
    }
  }

  /// Debe completarse antes de cargar banners, intersticiales o rewarded.
  static Future<bool> prepare() async {
    if (CalendarioAdUnits.banner == null) return false;
    final pending = _consentPreparation ??= _prepareOnce();
    try {
      final allowed = await pending;
      _adsAllowed.value = allowed;
      if (!allowed) _consentPreparation = null;
      return allowed;
    } catch (error, stackTrace) {
      debugPrint('[ADS] Preparación fallida: $error');
      debugPrintStack(stackTrace: stackTrace);
      _adsAllowed.value = false;
      _consentPreparation = null;
      return false;
    }
  }

  static Future<bool> _prepareOnce() async {
    final allowed = await _requestConsent();
    if (!allowed) {
      _adsAllowed.value = false;
      debugPrint('[ADS] UMP no autoriza solicitudes de anuncios.');
      return false;
    }
    await _initializeSdk();
    _adsAllowed.value = true;
    await preload();
    return true;
  }

  static Future<void> preload() async {
    if (!await _cachedConsentPermission()) return;
    await Future.wait<Object?>([_loadMenuInterstitial(), _loadRewarded()]);
  }

  static Future<InterstitialAd?> _loadMenuInterstitial() async {
    final unit = CalendarioAdUnits.interstitial;
    if (unit == null) return null;
    if (_menuAd != null) return _menuAd;
    if (_loadingMenu) {
      return _menuLoadCompleter?.future ?? Future<InterstitialAd?>.value();
    }

    _loadingMenu = true;
    final completer = Completer<InterstitialAd?>();
    _menuLoadCompleter = completer;
    try {
      await InterstitialAd.load(
        adUnitId: unit,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _menuAd = ad;
            _loadingMenu = false;
            if (!completer.isCompleted) completer.complete(ad);
          },
          onAdFailedToLoad: (error) {
            _loadingMenu = false;
            debugPrint('[ADS] Interstitial no disponible: $error');
            if (!completer.isCompleted) completer.complete(null);
          },
        ),
      );
    } catch (error) {
      _loadingMenu = false;
      debugPrint('[ADS] Error preparando interstitial: $error');
      if (!completer.isCompleted) completer.complete(null);
    }
    return completer.future;
  }

  static Future<void> showMenuInterstitial({
    required VoidCallback onComplete,
  }) async {
    late final int menuVisits;
    try {
      final preferences = await SharedPreferences.getInstance();
      menuVisits = (preferences.getInt(_menuVisitsPreferenceKey) ?? 0) + 1;
      await preferences.setInt(_menuVisitsPreferenceKey, menuVisits);
    } catch (error) {
      debugPrint('[ADS] No se pudo guardar el contador de menú: $error');
      onComplete();
      return;
    }

    // Primeras cinco entradas gratuitas; después, una impresión cada dos.
    // La sexta entrada también queda libre y se muestra en la séptima.
    final shouldShowAd =
        menuVisits > _freeMenuVisits && (menuVisits - _freeMenuVisits).isEven;
    debugPrint(
      '[ADS] Entrada al menú #$menuVisits; interstitial=$shouldShowAd',
    );
    if (!shouldShowAd) {
      onComplete();
      return;
    }

    final allowed = await prepare();
    if (!allowed) {
      onComplete();
      return;
    }

    final ad = _menuAd ?? await _loadMenuInterstitial();
    if (ad == null) {
      onComplete();
      unawaited(_loadMenuInterstitial());
      return;
    }

    _menuAd = null;
    var completed = false;
    void finish() {
      if (completed) return;
      completed = true;
      onComplete();
      unawaited(_loadMenuInterstitial());
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        finish();
      },
      onAdFailedToShowFullScreenContent: (shownAd, error) {
        debugPrint('[ADS] No se pudo mostrar interstitial: $error');
        shownAd.dispose();
        finish();
      },
    );
    ad.show();
  }

  static Future<RewardedAd?> _loadRewarded() async {
    final unit = CalendarioAdUnits.rewarded;
    if (unit == null) return null;
    if (_rewardedAd != null) return _rewardedAd;
    if (_loadingRewarded) {
      return _rewardedLoadCompleter?.future ?? Future<RewardedAd?>.value();
    }

    _loadingRewarded = true;
    final completer = Completer<RewardedAd?>();
    _rewardedLoadCompleter = completer;
    try {
      await RewardedAd.load(
        adUnitId: unit,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _loadingRewarded = false;
            if (!completer.isCompleted) completer.complete(ad);
          },
          onAdFailedToLoad: (error) {
            _loadingRewarded = false;
            debugPrint('[ADS] Rewarded no disponible: $error');
            if (!completer.isCompleted) completer.complete(null);
          },
        ),
      );
    } catch (error) {
      _loadingRewarded = false;
      debugPrint('[ADS] Error preparando rewarded: $error');
      if (!completer.isCompleted) completer.complete(null);
    }
    return completer.future;
  }

  /// La recompensa solo se comunica desde el callback oficial del SDK.
  static Future<bool> showRewarded({
    required void Function(int points) onRewardEarned,
  }) async {
    if (!await prepare()) return false;
    final ad = _rewardedAd ?? await _loadRewarded();
    if (ad == null) return false;

    _rewardedAd = null;
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        unawaited(_loadRewarded());
      },
      onAdFailedToShowFullScreenContent: (shownAd, error) {
        debugPrint('[ADS] No se pudo mostrar rewarded: $error');
        shownAd.dispose();
        unawaited(_loadRewarded());
      },
    );
    ad.show(
      onUserEarnedReward: (shownAd, reward) {
        if (earned) return;
        earned = true;
        onRewardEarned(10);
      },
    );
    return true;
  }
}
