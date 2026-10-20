import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const String _androidHomeBannerId = 'ca-app-pub-5849370961147264/1629081245';

Future<InitializationStatus>? _mobileAdsInitialization;

/// Inicializa el SDK una sola vez y comparte el mismo Future
/// entre el arranque de la app y las solicitudes de anuncios.
Future<InitializationStatus> initializeMobileAds() {
  return _mobileAdsInitialization ??= MobileAds.instance.initialize();
}

class AdsState {
  const AdsState({
    this.homeBanner,
    this.isLoading = false,
    this.isLoaded = false,
    this.attempts = 0,
    this.lastError,
    this.lastLoadDuration,
  });

  final BannerAd? homeBanner;
  final bool isLoading;
  final bool isLoaded;
  final int attempts;
  final String? lastError;
  final Duration? lastLoadDuration;
}

final adsProvider = NotifierProvider<AdsNotifier, AdsState>(
  AdsNotifier.new,
);

class AdsNotifier extends Notifier<AdsState> {
  @override
  AdsState build() {
    ref.onDispose(() {
      final ad = state.homeBanner;
      if (ad != null) {
        unawaited(ad.dispose());
      }
    });

    return const AdsState();
  }

  /// Garantiza que haya un banner disponible sin solicitarlo
  /// repetidamente si ya está cargando o se encuentra cargado.
  Future<void> ensureHomeBanner() async {
    // El banner actual solo se muestra en Android.
    if (kIsWeb || !Platform.isAndroid) return;

    if (state.isLoading || state.isLoaded) return;

    final nextAttempt = state.attempts + 1;
    final startedAt = DateTime.now();

    state = AdsState(
      isLoading: true,
      attempts: nextAttempt,
    );

    try {
      await initializeMobileAds();

      // Otra llamada pudo iniciarse mientras esperábamos al SDK.
      if (!state.isLoading || state.attempts != nextAttempt) return;

      final ad = BannerAd(
        adUnitId: _androidHomeBannerId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (loadedAd) {
            final elapsed = DateTime.now().difference(startedAt);

            debugPrint(
              '[ADS] Banner cargado en ${elapsed.inMilliseconds} ms',
            );

            state = AdsState(
              homeBanner: loadedAd as BannerAd,
              isLoaded: true,
              attempts: nextAttempt,
              lastLoadDuration: elapsed,
            );
          },
          onAdFailedToLoad: (failedAd, error) {
            final elapsed = DateTime.now().difference(startedAt);

            debugPrint(
              '[ADS] Error de carga: '
              'code=${error.code}, '
              'domain=${error.domain}, '
              'message=${error.message}, '
              'elapsedMs=${elapsed.inMilliseconds}',
            );

            unawaited(failedAd.dispose());

            state = AdsState(
              isLoading: false,
              attempts: nextAttempt,
              lastError: error.toString(),
              lastLoadDuration: elapsed,
            );
          },
          onAdImpression: (ad) {
            debugPrint(
              '[ADS] IMPRESIÓN registrada para ${ad.adUnitId}',
            );
          },
          onAdClicked: (ad) {
            debugPrint('[ADS] Clic en el banner');
          },
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {
            debugPrint(
              '[ADS] Evento de ingresos: '
              'valueMicros=$valueMicros, '
              'precision=$precision, '
              'currency=$currencyCode',
            );
          },
        ),
      );

      // El anuncio se conserva en el estado durante la carga.
      state = AdsState(
        homeBanner: ad,
        isLoading: true,
        attempts: nextAttempt,
      );

      await ad.load();
    } catch (error, stackTrace) {
      debugPrint('[ADS] No se pudo iniciar la carga: $error');
      debugPrintStack(stackTrace: stackTrace);

      final currentAd = state.homeBanner;
      if (currentAd != null) {
        unawaited(currentAd.dispose());
      }

      state = AdsState(
        isLoading: false,
        attempts: nextAttempt,
        lastError: error.toString(),
        lastLoadDuration: DateTime.now().difference(startedAt),
      );
    }
  }
}
