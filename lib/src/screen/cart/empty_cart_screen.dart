import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:cpcdiagnostics_ecommerce/src/controllers/dashboard_controller.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/app_tags.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/app_theme_data.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/responsive.dart';


class EmptyCartScreen extends StatelessWidget {
  EmptyCartScreen({Key? key}) : super(key: key);
  final homeScreenController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 90.h,
        ),
        SizedBox(
          width: 251.w,
          height: 200.h,
          child: SvgPicture.asset("assets/icons/empty_cart.svg"),
        ),
        SizedBox(
          height: 20.h,
        ),
        Text(
          "Your Inquiry list is empty",
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: "Poppins Medium",
            color: Colors.black,
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        SizedBox(
          width: 172.w,
          child: Text(
            "Add products to Inquiry list",
            style: isMobile(context)?AppThemeData.dateTextStyle_12:AppThemeData.dateTextStyle_9Tab,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 90.h,
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                homeScreenController.changeTabIndex(0);
              },
              style: ElevatedButton.styleFrom(
                primary: AppThemeData.headlineTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 5,
                shadowColor: AppThemeData.headlineTextColor,
              ),
              child: Text(
                "Continue Browsing",
                style: isMobile(context)? AppThemeData.buttonTextStyle_14:AppThemeData.buttonTextStyle_11Tab
              ),
            ),
          ),
        ),
      ],
    );
  }
}
