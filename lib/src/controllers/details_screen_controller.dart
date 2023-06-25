
import 'dart:developer';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:cpcdiagnostics_ecommerce/src/controllers/color_selection_controller.dart';
import 'package:cpcdiagnostics_ecommerce/src/data/local_data_helper.dart';
import 'package:cpcdiagnostics_ecommerce/src/models/product_details_model.dart';
import 'package:cpcdiagnostics_ecommerce/src/servers/repository.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/analytics_helper.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/constants.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/validators.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class DetailsPageController extends GetxController {
  PageController pageController = PageController();
  TextEditingController ratingController = TextEditingController();
  final _colorSelectionController = Get.put(ColorSelectionController());
  late double rating;
  double initialRating = 2.0;
  var isLoading = true.obs;
  var isDescription = false.obs;
  var isSpecific = false.obs;
  var isFavorite = false.obs;
  var isFavoriteLocal = false.obs;
  var hassleFree = false.obs;
  var groupProduct = false.obs;
  var isObsecure = true.obs;
  var isReviewLoading=true.obs;


  late Rx<AppLifecycleState> appState;

  IconData? selectedIcon;
  var productImageNumber = 0.obs;
  Rx<ProductDetailsModel> productDetail = ProductDetailsModel().obs;

  var openResult = 'Unknown'.obs;
  final _minimumOrderQuantity = 1.obs;
  var productQuantity = 1.obs;
  var totalPrice = 0.0.obs;
  String colorId = '';
  String colorValue = '';
  var pageView=0.obs;
  RxInt ordering = 0.obs;

  updatePageIncrement(){
    int imageLength = productDetail.value.data!.descriptionImages!.length;
    if(pageView<imageLength-1){
      pageView.value++;
    }
  }
  updatePageDecrement(){
    if(pageView>0){
      pageView.value--;
    }
  }

  var productId = Get.parameters['productId'];

  //PDf File Reader
  Future<void> openFile(var url) async {
    final result = await OpenFile.open(url);
    openResult.value = result.toString();
  }

  userReviewIndex() {
    printLog(LocalDataHelper().getUserAllData()!.data!.userId!);
    int lengthReview= productDetail.value.data!.reviews!.length;
    for(int i=0; i<=lengthReview;i++){
      if(productDetail.value.data!.reviews![i].user!.id==LocalDataHelper().getUserAllData()!.data!.userId!){
        return i;
      }
    }
  }


  File? image;
  late String imagePath;
  final _picker = ImagePicker();
  Future<void> getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery,imageQuality: 20);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      imagePath = pickedFile.path;
      printLog(imagePath);
      update();
    } else {
      printLog('No image selected.');
    }
  }

  generateDeepLink() async {
    FirebaseDynamicLinks firebaseDynamicLinks = FirebaseDynamicLinks.instance;
    var parameters = DynamicLinkParameters(
        link: Uri.parse("https://www.cpcdiagnostics.bizzonit.com?product_id=$productId"),
        uriPrefix: "https://cpcdiag.page.link",
        androidParameters: const AndroidParameters(packageName: 'com.bizzonit.cpcdiagnostics'),
    );
    var shortLink = await firebaseDynamicLinks.buildLink(parameters);
    Share.share(
         shortLink.toString(),
        subject: productDetail.value.data!.title
    );
  }



  Future postReviewSubmit({
    required String productId,
    required String title,
    required String comment,
    required String rating,
    File? image,
  }) async {
    isReviewLoading.value=false;
    await Repository().postReviewSubmit(
        productId: productId,
        title: title,
        comment: comment,
        rating: rating,
        image: image).then((value) {
          isReviewLoading.value=true;
    });
    isReviewLoading.value=true;
    update();
  }

  Future likeAndUnlike({required int reviewId}) async {
    await Repository().getLikeAndUnlike(reviewId: reviewId);
    update();
  }

  isObsecureUpdate() {
    isObsecure.value = !isObsecure.value;
  }

  isFavoriteUpdate() {
    isFavorite.value = !isFavorite.value;
  }

  isFavoriteLocalUpdate() {
    isFavoriteLocal.value = !isFavoriteLocal.value;
  }

  itemCounterUpdate(value) {
    productImageNumber.value = value;
  }

  isDeliveryUpdate() {
    isDescription.value = !isDescription.value;
  }

  ratingUpdate(double value) {
    rating = value;
  }

  isSpecificUpdate() {
    isSpecific.value = !isSpecific.value;
  }

  Future setProductVariantData(ProductDetailsModel data) async {
    if (data.data!.hasVariant!) {
      _colorSelectionController.setAttrData(data.data!.attributes!.length,
          data.data!.attributes!, data.data!.colors!);
    }
  }

  Future<ProductDetailsModel> getProductDetails(int proId) async {
    return await Repository().getProductDetails(proId).then((value) {
      log(value.toString());
      productDetail.value = value;
      ordering.value = productDetail.value.data!.ordering!;
      _minimumOrderQuantity.value = value.data!.minimumOrderQuantity ?? 1;
      productQuantity.value = _minimumOrderQuantity.value;
      //calculate total price
      calculateTotalPrice();
      setProductVariantData(value);
      isFavorite(value.data!.isFavourite);
      AnalyticsHelper().setAnalyticsData(
          screenName: "ProductDetailsScreen",
          eventTitle: "ProductDetails",
          additionalData: {
            "productId": proId,
            "price": value.data != null ? value.data!.price : null,
          });
      isLoading(false);
      update();
      return value;
    });
  }

  incrementProductQuantity() {
    if (productQuantity.value < productDetail.value.data!.currentStock!) {
      productQuantity.value++;
      calculateTotalPrice();
    } else {
      showErrorToast("No more product in stock");
    }
    update();
  }

  decrementProductQuantity() {
    if (productQuantity.value > _minimumOrderQuantity.value) {
      productQuantity.value--;
      calculateTotalPrice();
    } else {
      showErrorToast(
          "Please order a minium amount of ${_minimumOrderQuantity.value}");
    }
    update();
  }

  bool isValidToAddToCart() {
    if (productQuantity.value >= _minimumOrderQuantity.value) {
      return true;
    } else {
      showErrorToast(
          "Please order a minium amount of ${_minimumOrderQuantity.value}");
      return false;
    }
  }


  @override
  void onInit() {
    super.onInit();
    print('DetailsPageController init');
    productImageNumber = 0.obs;
    ratingController = TextEditingController(text: '3.0');
    rating = initialRating;
    getProductDetails(int.parse(productId.toString()));
  }

  updateColorId(String value) {
    colorId = value;
    update();
  }

  updateColorValue(String value) {
    colorValue = value;
    update();
  }

  void calculateTotalPrice() {
    double price =
        productQuantity.value * double.parse(productDetail.value.data!.price);
    if (productDetail.value.data != null) {
      if (productDetail.value.data!.isWholesale &&
          productDetail.value.data!.wholesalePrices != null) {
        for (var wholesale in productDetail.value.data!.wholesalePrices!) {
          if (productQuantity.value >= wholesale.minQty &&
              productQuantity.value <= wholesale.maxQty) {
            price = productQuantity.value * double.parse(wholesale.price);
          }
        }
      }
    }
    totalPrice.value = price;
    update();
  }

  String path = "";
  RxDouble downloadProgress = 0.0.obs;
  downloadBrochure(String pdf) async {
    Directory _path = await getApplicationDocumentsDirectory();
    String _localPath = '${_path.path}${Platform.pathSeparator}Download';
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    path = _localPath;
    DownloaderCore core;
    DownloaderUtils options;
    options = DownloaderUtils(
      progressCallback: (current, total) {
        final progress = (current / total) * 100;
        downloadProgress.value = progress;
        update();
      },
      file: File('$path/loremipsum.pdf'),
      progress: ProgressImplementation(),
      onDone: () {
        print('file downloaded');
        OpenFile.open('$path/loremipsum.pdf');
      },
      deleteOnCancel: true,
    );
    core = await Flowder.download(
      "https://cpcdiagnostics.bizzonit.com/public/$pdf",
      options,
    );
  }

  @override
  void onClose() {
    Get.delete<ColorSelectionController>();
    super.onClose();
  }
}
