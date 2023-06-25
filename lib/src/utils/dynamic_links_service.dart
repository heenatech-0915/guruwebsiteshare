import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../_route/routes.dart';

class DynamicLinksService{

  Future handleDynamicLinks() async {

    //App opened from dynamic links
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    if (data != null) {
      Uri uri = data.link;
      dynamic queryParameters = uri.queryParameters;
      if (queryParameters != null && queryParameters['product_id'] != null) {
        Get.toNamed(
          Routes.detailsPage,
          parameters: {
            'productId': queryParameters['product_id'],
          },
        );
      }
    }

    //App brought to foreground from background
    final FirebaseDynamicLinks firebaseDynamicLinks =  FirebaseDynamicLinks.instance;
    firebaseDynamicLinks.onLink.listen((event) {
        Uri uri = event.link;
        dynamic queryParameters = uri.queryParameters;
        if (queryParameters != null && queryParameters['product_id'] != null) {
             GetStorage().write('product_id',queryParameters['product_id']);
        }
    });

  }
}