import 'package:get/get.dart';
import 'package:cpcdiagnostics_ecommerce/src/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}
