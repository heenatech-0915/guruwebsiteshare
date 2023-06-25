import 'package:cpcdiagnostics_ecommerce/src/screen/home/product_details/brochure_pdf_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pagination_view/pagination_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../_route/routes.dart';
import '../../controllers/brochures_controller.dart';
import '../../utils/app_tags.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/responsive.dart';
import '../../widgets/loader/shimmer_load_data.dart';
import '../../widgets/loader/shimmer_products.dart';

class BrochuresScreen extends StatelessWidget {
   BrochuresScreen({Key? key}) : super(key: key);

  BrochuresController vc = Get.put(BrochuresController());

  @override
  Widget build(BuildContext context) {
    for (var element in vc.pdf) {
      if (kDebugMode) {
        print(element.specification);
      }
    }
    return Column(
      children: [

        SizedBox(
          height: 100.h,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              "Brochures",
              style: isMobile(context)? AppThemeData.headerTextStyle_16:AppThemeData.headerTextStyle_14,
            ).paddingSymmetric(vertical: 20.h),
          ),
        ),

        Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.height/1.2,
            child: LayoutBuilder(builder: (context,constraints){
              return Obx((){
                return NotificationListener<ScrollNotification>(
                  onNotification: (notification){
                    if (notification is ScrollEndNotification && notification.metrics.pixels >=notification.metrics.maxScrollExtent && !vc.isLoading.value) {
                      vc.getBrochuresData();
                    }
                    return false;
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                            padding: EdgeInsets.all(8.w),
                            itemCount: vc.pdf.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2,
                                crossAxisSpacing: 10.w,
                                mainAxisSpacing: 10.w
                            ),
                            itemBuilder: (context,index){
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(7.r)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppThemeData.boxShadowColor.withOpacity(0.1),
                                      spreadRadius: 0,
                                      blurRadius: 20.r,
                                      offset: const Offset(0, 10), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(()=>BrochurePdfPage(pdfUrl: vc.pdf[index].specification,brochuresPage:true,title: vc.pdf[index].title!,));
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      SizedBox(width: 10.w),
                                      const Icon(Icons.picture_as_pdf),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          vc.pdf[index].title!,
                                          style: TextStyle(color: AppThemeData.primaryColor),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                      ),

                      vc.isLoading.value ? CircularProgressIndicator():SizedBox()
                    ],
                  ),
                );
              });
            }),
          ),
        ),

      ],
    );

  }
}
