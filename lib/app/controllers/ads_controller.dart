import 'dart:io';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsController extends GetxController {

  final String _adHomeId = Platform.isAndroid
      ? 'ca-app-pub-5849370961147264/3151373239'
      : 'ca-app-pub-3940256099942544/2934735716';

  final String _adNotesListId = Platform.isAndroid
      ? 'ca-app-pub-5849370961147264/4637413038'
      : 'ca-app-pub-3940256099942544/2934735716';

  final String _adCuadrantesListId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  final String _adTurnosListId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  final String _adCrearNotasListId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static const unitId = 'ca-app-pub-3940256099942544/6300978111';


  late BannerAd staticHomeAd;
  late BannerAd staticNotesListAd;
  late BannerAd staticCuadrantesListAd;
  late BannerAd staticCrearNotasLisAd;
  late BannerAd staticTurnosListAd;


  late BannerAd bannerAd;
  bool isLoaded = false;

  RxBool staticAdHomeLoaded = false.obs;
  RxBool staticAdNotesListLoaded = false.obs;
  RxBool staticAdCuadrantesListLoaded = false.obs;
  RxBool staticAdCrearNotasLoaded = false.obs;
  RxBool staticAdTurnosListLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeBannerAd();
    loadNotesListBannerAd();
    loadAd();
  }

  void loadHomeBannerAd() {

    staticHomeAd = BannerAd(
        adUnitId: _adHomeId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (ad) {
          staticAdHomeLoaded.value = true;
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }));

    staticHomeAd.load();
  }

 void loadNotesListBannerAd() {
    staticNotesListAd = BannerAd(
        adUnitId: _adNotesListId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (ad) {
          staticAdNotesListLoaded.value = true;
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }));

    staticNotesListAd.load();
  }

 void loadCuadrantesListBannerAd() {
    staticCuadrantesListAd = BannerAd(
        adUnitId: _adCuadrantesListId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (ad) {
          staticAdCuadrantesListLoaded.value = true;
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }));

    staticCuadrantesListAd.load();
  }

 void loadCrearNotasListBannerAd() {
    staticCrearNotasLisAd = BannerAd(
        adUnitId: _adCrearNotasListId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (ad) {
          staticAdCrearNotasLoaded.value = true;
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }));

    staticCrearNotasLisAd.load();
  }

 void loadTurnosListBannerAd() {
    staticTurnosListAd = BannerAd(
        adUnitId: _adTurnosListId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (ad) {
          staticAdTurnosListLoaded.value = true;
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }));

    staticTurnosListAd.load();
  }












  void loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        Get.size.width.truncate());

    if (size == null) {
      // Unable to get width of anchored banner.
      return;
    }

    BannerAd(
      adUnitId: _adHomeId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {

            bannerAd = ad as BannerAd;
            isLoaded = true;
          update();
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }

  @override
  void dispose() {
    bannerAd.dispose();
    super.dispose();
  }




}
