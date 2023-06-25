import 'package:cpcdiagnostics_ecommerce/src/controllers/dashboard_controller.dart';
import 'package:get/get.dart';
import 'package:cpcdiagnostics_ecommerce/src/models/add_to_cart_list_model.dart';
import 'package:cpcdiagnostics_ecommerce/src/models/coupon_applied_list.dart';
import 'package:cpcdiagnostics_ecommerce/src/servers/repository.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/analytics_helper.dart';
import 'package:cpcdiagnostics_ecommerce/src/data/local_data_helper.dart';
import 'package:get_storage/get_storage.dart';

import '../_route/routes.dart';

class CartContentController extends GetxController {

  final Rx<AddToCartListModel> _addToCartListModel = AddToCartListModel().obs;
  AddToCartListModel get addToCartListModel => _addToCartListModel.value;
  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  final _isCartUpdating = false.obs;
  bool get isCartUpdating => _isCartUpdating.value;
  final _updatingCartId = "".obs;
  String get updatingCartId => _updatingCartId.value;
  final _isIncreasing = false.obs;
  bool get isIncreasing => _isIncreasing.value;
  final Rx<CouponAppliedList> _appliedCouponList = CouponAppliedList().obs;
  CouponAppliedList get appliedCouponList => _appliedCouponList.value;
  final _isAplyingCoupon = false.obs;
  bool get isAplyingCoupon => _isAplyingCoupon.value;
  RxBool isAddingToCart = false.obs;
  RxBool isBooking = false.obs;
  RxString productBeingRemoved = "".obs;


  var couponCode = ''.obs;
  DashboardController dashboardController = Get.find<DashboardController>();


  @override
  void onInit() {
    getCartList();
    getAppliedCouponList();
    super.onInit();
  }

  Future getCartList({bool isShowLoading = true}) async {
    _isLoading(isShowLoading);
    await Repository().getCartItemList().then((value) {
      _addToCartListModel.value = value;
      _isLoading(false);
    });
    update();
    dashboardController.getAddToCartList();
  }

  Future addToCart(
      {required String productId,
      required String quantity,
      required String variantsIds,
      required String variantsNames}) async {
    AnalyticsHelper().setAnalyticsData(
        screenName: "ProductDetailsScreen",
        eventTitle: "AddToCart",
        additionalData: {
          "productId": productId,
          "quantity": quantity,
          "variantsNames": variantsNames,
        });
    String? trxId = LocalDataHelper().getCartTrxId();
    //q7ML8ZzuK8wxxxQouw7zD
    print("trxId ---> $trxId");
    isAddingToCart.value = true;
    if (trxId == null) {
      Repository()
          .addToCartWithOutTrxId(
            productId: productId,
            quantity: quantity,
            variantsIds: variantsIds,
            variantsNames: variantsNames,
          )
          .then((value){
            getCartList(isShowLoading: false);
            isAddingToCart.value = false;
          });
    } else {
      Repository()
          .addToCartWithTrxId(
              productId: productId,
              quantity: quantity,
              variantsIds: variantsIds,
              variantsNames: variantsNames,
              trxId: trxId)
          .then((value){
            getCartList(isShowLoading: false);
            isAddingToCart.value = false;
          });
    }
  }

  Future deleteAProductFromCart({required String productId}) async {
    productBeingRemoved.value = productId;
    await Repository().deleteCartProduct(productId: productId).then((value) {
      getCartList(isShowLoading: false);
       AnalyticsHelper().setAnalyticsData(
          screenName: "ProductDetailsScreen",
          eventTitle: "DeleteFromCart",
          additionalData: {
            "productId": productId,
          });
       productBeingRemoved.value = "";
    }).whenComplete((){
      productBeingRemoved.value = "";
    });
  }

  Future updateCartProduct(
      {required String cartId,
      required int quantity,
      required bool increasing}) async {
    _isCartUpdating(true);
    _isIncreasing(increasing);
    _updatingCartId.value = cartId;
    await Repository()
        .updateCartProduct(cartId: cartId, quantity: quantity)
        .then((value) {
      getCartList(isShowLoading: false);
      _isCartUpdating(false);
      _updatingCartId.value = "";
    });
    update();
  }

  Future getAppliedCouponList() async {
    await Repository().getAppliedCouponList().then((value) {
      _appliedCouponList.value = value;
    });
  }

  Future applyCouponCode({required String code}) async {
    _isAplyingCoupon(true);
    await Repository().applyCouponCode(couponCode: code).then((value) {
      getAppliedCouponList();
      _isAplyingCoupon(false);
    });
  }

  Future order() async {
    isBooking.value = true;
    await Repository().orderProducts().then((value){
      isBooking.value = false;
      dashboardController.changeTabIndex(0);
      LocalDataHelper().box.remove("trxId");
    }).whenComplete(() => isBooking.value=false);
  }
}
