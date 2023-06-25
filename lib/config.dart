import 'package:flutter/material.dart';

class Config {
  // copy your server url from admin panel
  static String apiServerUrl = "https://cpcdiagnostics.bizzonit.com/api";
  // copy your api key from admin panel
  static String apiKey = "QK3VBBXBY06TDZOV";

  //enter onesignal app id below
  static String oneSignalAppId = "285f270a-3df8-4781-85da-6864142fdf6a";
  // find your ios APP id from app store
  static const String iosAppId = "";
  static const bool enableGoogleLogin = true;
  static const bool enableFacebookLogin = true;

  static var supportedLanguageList = [
    const Locale("en", "US"),
    const Locale("bn", "BD"),
    const Locale("ar", "SA"),
  ];
  static const String initialCountrySelection = "BD";
}
