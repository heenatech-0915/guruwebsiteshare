import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_theme_data.dart';
import '../utils/responsive.dart';

class ButtonWidget extends StatelessWidget {
  final String? buttonTittle;
  const ButtonWidget({
    Key? key,
    this.buttonTittle,
    this.isLoading = false
  }) : super(key: key);
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 48.h,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              spreadRadius: 2,
              blurRadius: 10,
              color: AppThemeData.buttonShadowColor.withOpacity(0.3),
              offset: const Offset(0, 5))
        ],
        color: AppThemeData.buttonColor,
        borderRadius:  BorderRadius.all(
          Radius.circular(10.r),
        ),
      ),
      child: !isLoading?Text(
        buttonTittle!,
        style: isMobile(context)? AppThemeData.buttonTextStyle_14:AppThemeData.buttonTextStyle_11Tab,
      ):SizedBox.square(
          dimension: 30.w,
          child: CircularProgressIndicator(strokeWidth: 2,color: AppThemeData.primaryColor)
      ),
    );
  }
}
