import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test Ad Unit ID
    } else {
      return 'ca-app-pub-9644610197219419/1722377871'; // Replace with your real Ad Unit ID
    }
  }

  static String? get interstitialAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test Ad Unit ID
    } else {
      return 'ca-app-pub-9644610197219419/1488242452'; // Replace with your real Ad Unit ID
    }
  }

  static final BannerAdListener bannerListner = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('Ad loaded: ${ad.responseInfo}'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('Ad failed to load: $error');
    },
    onAdOpened: (ad) => debugPrint('Ad opened'),
    onAdClosed: (ad) => debugPrint('Ad closed'),
  );
}
