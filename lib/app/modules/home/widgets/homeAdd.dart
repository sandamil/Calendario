import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdmob extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _BannerAdmobState();
  }
}

class _BannerAdmobState extends State<BannerAdmob>{
  final String _adHomeId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  late BannerAd _bannerAd;
  bool _bannerReady = false;

  @override
  void initState() {

   super.initState();
    _bannerAd = BannerAd(
      adUnitId: _adHomeId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _bannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          setState(() {
            _bannerReady = false;
          });
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _bannerReady?SizedBox(
      width: _bannerAd.size.width.toDouble(),
      height: _bannerAd.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd),
    ):Container();
  }
}