import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../controllers/ads_service.dart';

/// Banner reutilizable para el pie de hojas y diálogos.
class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({super.key, this.centered = true});

  final bool centered;

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    CalendarioAds.adsPermission.addListener(_onAdsPermissionChanged);
    if (CalendarioAds.canRequestAds) _load();
  }

  void _onAdsPermissionChanged() {
    if (CalendarioAds.canRequestAds) _load();
  }

  Future<void> _load() async {
    final unit = CalendarioAdUnits.banner;
    if (unit == null || kIsWeb || !CalendarioAds.canRequestAds || _ad != null) {
      return;
    }
    final ad = BannerAd(
      adUnitId: unit,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted) {
            loadedAd.dispose();
            return;
          }
          setState(() {
            _ad = loadedAd as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (failedAd, error) {
          debugPrint('[ADS] Banner de popup no disponible: $error');
          failedAd.dispose();
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    CalendarioAds.adsPermission.removeListener(_onAdsPermissionChanged);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: SizedBox(
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
