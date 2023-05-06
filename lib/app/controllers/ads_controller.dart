import 'dart:io';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsController extends GetxController {

  final String _adHomeId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  final String _adNOtesListId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static const unitId = 'ca-app-pub-3940256099942544/6300978111';


  late BannerAd staticAd;


  late BannerAd bannerAd;
  bool isLoaded = false;

  RxBool staticAdLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeBannerAd();
    loadAd();
  }

  void loadHomeBannerAd() {
    staticAd = BannerAd(
        adUnitId: _adHomeId,
        size: AdSize.banner,
        request: AdRequest(),
        listener: BannerAdListener(onAdLoaded: (ad) {
          staticAdLoaded.value = true;
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }));

    staticAd.load();
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
