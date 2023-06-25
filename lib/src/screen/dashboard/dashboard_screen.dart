import 'package:badges/badges.dart'as badge;
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cpcdiagnostics_ecommerce/src/controllers/dashboard_controller.dart';
import 'package:cpcdiagnostics_ecommerce/src/screen/cart/cart_screen.dart';
import 'package:cpcdiagnostics_ecommerce/src/screen/category/category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/app_theme_data.dart';
import 'package:get_storage/get_storage.dart';
import '../../_route/routes.dart';
import '../../controllers/cart_content_controller.dart';
import '../brochures/brochures_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({Key? key}) : super(key: key);
  final homeController = Get.find<DashboardController>();
  final cartContentController = Get.put(CartContentController());
  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance
        .addPostFrameCallback((_){
          handleDeeplink();
    });
    return Obx(
      () => DoubleBack(
        message: "Press back again to close",
        child: Scaffold(
          body: IndexedStack(
            index: homeController.tabIndex.value,
            children: [
              HomeScreenContent(),
              CategoryScreen(),
              const CartScreen(),
              BrochuresScreen(),
              const ProfileContent()
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            backgroundColor: Colors.white,
            selectedFontSize: 12.r,
            onTap: homeController.changeTabIndex,
            currentIndex: homeController.tabIndex.value,
            selectedItemColor: AppThemeData.buttonColor,
            selectedLabelStyle: const TextStyle(color: AppThemeData.headlineTextColor),
            elevation: 5.0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  activeIcon: _bottomNavIconBuilder(
                      isSelected: homeController.tabIndex.value == 0,
                      logo: "home",
                      height: 25.w,
                      width: 25.h,
                      title: "Home"
                  ),
                  icon: _bottomNavIconBuilder(
                      isSelected: homeController.tabIndex.value == 0,
                      logo: "home",
                      height: 21.h,
                      width: 21.w,
                      title: "Home"
                  ),
                  label: "Home",
                  backgroundColor: Colors.white),
              BottomNavigationBarItem(
                  activeIcon: _bottomNavIconBuilder(
                      isSelected: homeController.tabIndex.value == 1,
                      logo: "category_",
                      height: 25.h,
                      width: 25.w,
                      title: "Category"
                  ),
                  icon: _bottomNavIconBuilder(
                      isSelected: homeController.tabIndex.value == 1,
                      logo: "category_",
                      height: 21.h,
                      width: 21.w,
                      title: "Category"
                  ),
                  label: "Category",
                  backgroundColor: Colors.white),
              BottomNavigationBarItem(
                  activeIcon: _bottomNavIconBuilder(
                      isSelected: homeController.tabIndex.value == 2,
                      logo: "cart_",
                      height: 25.h,
                      width: 25.w,
                      isCart: true,
                      title: "Inquiry"
                  ),
                  icon: _bottomNavIconBuilder(
                      isSelected: homeController.tabIndex.value == 2,
                      logo: "cart_",
                      height: 21.h,
                      width: 21.w,
                      isCart: true,
                      title: "Inquiry"
                  ),
                  label: "Cart",
                  backgroundColor: Colors.white),
              BottomNavigationBarItem(
                  activeIcon: _bottomNavIconBuilder(
                      isSelected: homeController.tabIndex.value == 3,
                      logo: "brochure",
                      height: 25.h,
                      width:  25.w,
                      title: "Brochures"
                  ),
                  icon: _bottomNavIconBuilder(
                      isSelected: homeController.tabIndex.value == 3,
                      logo: "brochure",
                      height: 21.h,
                      width: 21.w,
                      title: "Brochures"
                  ),
                  label: "Favorite",
                  backgroundColor: Colors.white),
              BottomNavigationBarItem(
                activeIcon: _bottomNavIconBuilder(
                    isSelected: homeController.tabIndex.value == 4,
                    logo: "profile_",
                    height: 25.h,
                    width: 25.w,
                    title: "Profile"
                ),
                icon: _bottomNavIconBuilder(
                  isSelected: homeController.tabIndex.value == 4,
                    logo: "profile_",
                    height: 21.h,
                    width: 21.w,
                    title: "Profile"
                ),
                label: "Profile",
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavIconBuilder({
    required bool isSelected,
    required String logo,
    required double height,
    required double width,
    bool isCart = false,
    required String title
  }) {
    return isCart && isSelected
        ? AnimatedContainer(
            height: 35.h,
            width: !isSelected ? 20.w : 80.w,
            decoration: isSelected
                ? BoxDecoration(
                    color: AppThemeData.primaryColor,
                    borderRadius: BorderRadius.circular(7),
                  )
                : null,
            duration: const Duration(milliseconds: 500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                badge.Badge(
                    animationDuration: const Duration(milliseconds: 300),
                    animationType: badge.BadgeAnimationType.slide,
                    badgeContent: Text(
                      homeController.addToCartListModel!.data != null
                          ? homeController.addToCartListModel!.data!.carts != null
                              ? homeController
                                  .addToCartListModel!.data!.carts!.length
                                  .toString()
                              : "0"
                          : "0",
                      style: TextStyle(color: Colors.white, fontSize: 9.sp),
                    ),
                    child: const Icon(
                      Icons.list_alt,
                      color: Colors.orangeAccent,
                    )),
                SizedBox(width: 5.w,),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  maxLines: 2,
                )
              ],
            ),
          )
        : isCart? badge.Badge(
                animationDuration: const Duration(milliseconds: 300),
                animationType: badge.BadgeAnimationType.slide,
                badgeContent: Text(
                  homeController.addToCartListModel!.data != null
                      ? homeController.addToCartListModel!.data!.carts != null
                          ? homeController
                              .addToCartListModel!.data!.carts!.length
                              .toString()
                          : "0"
                      : "0",
                  style: TextStyle(color: Colors.white, fontSize: 9.sp),
                ),
                child: const Icon(
                  Icons.list_alt,
                  color: Colors.orangeAccent,
                ))
            : AnimatedContainer(
                height: 35.h,
                width: !isSelected ? 20.w : 95.w,
                decoration: isSelected
                    ? BoxDecoration(
                        color: AppThemeData.primaryColor,
                        borderRadius: BorderRadius.circular(7),
                      )
                    : null,
                duration: const Duration(milliseconds: 500),
                child: !isSelected
                    ? SvgPicture.asset(
                        "assets/icons/$logo.svg",
                        height: height,
                        width: width,
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SvgPicture.asset(
                              "assets/icons/$logo.svg",
                              height: height,
                              width: width,
                            ),
                          ),
                          Expanded(
                              flex: 5,
                              child: Text(
                                title,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
              );
  }

  handleDeeplink(){
    if(GetStorage().read('product_id')!=null){
      Get.toNamed(
        Routes.detailsPage,
        parameters: {
          'productId': GetStorage().read('product_id'),
        },
      );
      GetStorage().remove('product_id');
    }
  }
}
