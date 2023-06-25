import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme_data.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        title: Text(
          'Technical Support',
          style: AppThemeData.headerTextStyle_16,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const Image(
              image: AssetImage('assets/logos/support.png'),
            ),

            SizedBox(height: 20.h),

            Text(
              'Remote support available for quick technical support.',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600
              ),
            ),

            SizedBox(height: 8.h),

            Padding(
              padding: const EdgeInsets.only(left: 30.0,right: 30,top: 7,bottom: 20),
              child: Text(
                'Call the below toll-free number to resolve your mechanical and application issues.',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400
                ),
              ),
            ),

            SizedBox(height: 30.h),

            Container(
              width: MediaQuery.of(context).size.width/2,
              height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppThemeData.primaryColor.withOpacity(0.1),
                border: Border.all(color: AppThemeData.primaryColor,width: 1.w)
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              child: InkWell(
                onTap: (){},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    InkWell(
                      onTap: () async {
                        var url = Uri.parse("tel:18004251101");
                        if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                        } else {
                        throw 'Could not launch $url';
                        }
                      },
                      child: Row(
                        children:  [

                          Icon(Icons.phone, color: AppThemeData.primaryColor),

                          SizedBox(width: 15.w),

                          const Text('1800 425 1101')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30.h),

            Container(
              width: MediaQuery.of(context).size.width/2,
              height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppThemeData.primaryColor.withOpacity(0.1),
                border: Border.all(color: AppThemeData.primaryColor,width: 1.w)
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              child: InkWell(
                onTap: (){},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    InkWell(
                      onTap: () async {
                        var url = Uri.parse("tel:18004251105");
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Row(
                        children:  [

                          Icon(Icons.phone, color: AppThemeData.primaryColor),

                          SizedBox(width: 15.w),

                          const Text('1800 425 1105')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
