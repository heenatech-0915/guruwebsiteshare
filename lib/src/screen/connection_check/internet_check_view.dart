import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_tags.dart';

class InternetCheckView extends StatelessWidget {
  const InternetCheckView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 90.h,
                width: 90.w,
                child: Image.asset("assets/images/nointernet.png"),
            ),
            SizedBox(height: 10.h,),
             Text(AppTags.pleaseCheckYourInternet.tr)
          ],
        ),
      ),
    );
  }
}
