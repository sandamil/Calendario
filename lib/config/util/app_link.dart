import 'package:flutter/foundation.dart';
import 'dart:io';

class AppLink {
  static const String androidAppPackageName = "ajat.calendario.turnos";
  static const String _playStoreUrl = "https://play.google.com/store/apps/details?id=$androidAppPackageName";
  static const String _appleStoreUrl = "https://apps.apple.com/tw/app/id*********";

  static const String githubOwnerName = "sandamil";
  static const String appRepoName = "Calendario";
  static const String appFilesRepoName = "CalendarioFiles";

  static const String tatGitHubRepoUrlString = "https://github.com/$githubOwnerName/$appRepoName";
  static const String privacyPolicyUrlString =
      'https://raw.githubusercontent.com/$githubOwnerName/$appFilesRepoName/main/privacy-policy.md';

  // TODO: set this to be a remote-config.
  static final feedbackBaseUrl =
      Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLSc3JFQECAA6HuzqybasZEXuVf8_ClM0UZYFjpPvMwtHbZpzDA/viewform');

  static Uri feedbackUrl(String mainVersion, String log) => Uri.https(
        feedbackBaseUrl.host,
        feedbackBaseUrl.path,
        {
          "entry.978972557": ((!kIsWeb && defaultTargetPlatform == TargetPlatform.android)) ? "Android" : "IOS",
          "entry.823909330": mainVersion,
          "entry.517392071": log,
        },
      );

  static String get storeUrlString => ((!kIsWeb && defaultTargetPlatform == TargetPlatform.android)) ? _playStoreUrl : _appleStoreUrl;
}
