import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme_data.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeData.bgColor,
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
          'Contact Us',
          style: AppThemeData.headerTextStyle_16,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:  [
             Icon(Icons.location_on_outlined,color: AppThemeData.primaryColor,size: 30,),

            SizedBox(height: 10.h),

            SizedBox(
              width: 200.w,
              child: const Text(
                  'Flat No.9, Gokul Towers, Fifth Floor No. 9 &10 C.P.Ramaswami Road, Alwarpet, Chennai-600018. ',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
              ),
            ),

            SizedBox(height: 30.h),

            Icon(Icons.phone_iphone,color: AppThemeData.primaryColor,size: 30,),

            SizedBox(height: 10.h),

            SizedBox(
              width: 200.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: () async {
                        var url = Uri.parse("tel:918754468400");
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                        elevation: 2,
                        child: Container(
                          width: 30.w,
                          height: 30.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppThemeData.primaryColor,
                          ),
                          child:const Icon(Icons.phone,size: 17,color: Colors.white,),
                        ),
                      )
                  ),
                  SizedBox(width: 5.h),
                  const Text(
                    '+918754468400',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            Icon(Icons.mail,color: AppThemeData.primaryColor,size: 30,),

            SizedBox(height: 10.h),

            const Text(
              'marketing@cpcdiagnostics.in',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal
              ),
              maxLines: 3,
            ),

            SizedBox(height: 100.h),

            const Text(
              'Follow Us',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal
              ),
              maxLines: 3,
            ),

            SizedBox(height: 5.h),

            SizedBox(
              width: 200.w,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap:(){
                      launchUrlInBrowser(url: "https://www.facebook.com/EverlifeCPC");
                    },
                    child: IconWrap(
                      child: SvgPicture.asset(
                          "assets/icons/facebook.svg"
                      ),
                    ),
                  ),

                  InkWell(
                    onTap:(){
                      launchUrlInBrowser(url: "https://www.youtube.com/@everlife-cpcdiagnostics");
                    },
                    child: IconWrap(
                      child: SvgPicture.asset(
                          "assets/icons/youTube.svg"
                      ),
                    ),
                  ),

                  InkWell(
                    onTap:(){
                      launchUrlInBrowser(url: "https://www.instagram.com/everlife_cpc_diagnostics");
                    },
                    child: IconWrap(
                      child: SvgPicture.asset(
                          "assets/icons/instagramblack.svg"
                      ),
                    ),
                  ),

                  InkWell(
                    onTap:(){
                      launchUrlInBrowser(url: "https://www.linkedin.com/company/everlife-cpc-diagnostics/");
                    },
                    child: IconWrap(
                      child: SvgPicture.asset(
                          "assets/icons/linkedIn.svg"
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  launchUrlInBrowser({String url =''}) async {
    var webUrl = Uri.parse(url);
    if (await canLaunchUrl(webUrl)) {
    await launchUrl(webUrl);
    } else {
    throw 'Could not launch $webUrl';
    }
  }

  Widget IconWrap({Widget ?child}){

    return Container(
      width: 50.w,
      height: 40.h,
      padding: EdgeInsets.all(5.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12,offset: Offset(1,1),blurRadius: 3)
        ]
      ),
      child: child,
    );
  }
}
