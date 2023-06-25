import 'dart:developer';
import 'package:cpcdiagnostics_ecommerce/src/_route/route_service.dart';
import 'package:cpcdiagnostics_ecommerce/src/bindings/splash_binding.dart';
import 'package:cpcdiagnostics_ecommerce/src/screen/splash/splash_screen.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/app_theme_data.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/dynamic_links_service.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cpcdiagnostics_ecommerce/src/_route/routes.dart';
import 'package:cpcdiagnostics_ecommerce/src/bindings/init_bindings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cpcdiagnostics_ecommerce/src/controllers/init_controller.dart';
import 'src/data/data_storage_service.dart';
import 'src/languages/language_translation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialConfig();
  await Firebase.initializeApp();
  final firebaseMessaging = FCM();
  firebaseMessaging.setNotifications();
  await GetStorage.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

Future<void> initialConfig() async {
  await Get.putAsync(() => StorageService().init());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final storage = Get.put(StorageService());
  final initController = Get.put(InitController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return GetMaterialApp(
          navigatorObservers: <NavigatorObserver>[initController.observer],
          initialBinding: InitBindings(),
          locale: storage.languageCode != null
              ? Locale(storage.languageCode!, storage.countryCode)
              : const Locale('en', 'US'),
          translations: AppTranslations(),
          fallbackLocale: const Locale('en', 'US'),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: Colors.blue,
              checkboxTheme: CheckboxThemeData(
                  fillColor:
                      MaterialStateProperty.all(AppThemeData.primaryColor))),
          initialRoute: Routes.splashScreen,
          onUnknownRoute: (v) {
            log('unknown route ${v.name.toString()}');
            return MaterialPageRoute(builder: (_) {
              return const SplashScreen();
            });
          },
          unknownRoute: GetPage(
            name: "/splashScreen",
            page: () => const SplashScreen(),
            binding: SplashBinding(),
          ),
          getPages: Routes.list,
          onGenerateRoute: RouterService().onGenerateRoute,
        );
      },
    );
  }
}
