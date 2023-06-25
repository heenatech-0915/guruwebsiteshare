import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AllProductsScreenController extends GetxController{


  RxBool filterByName = true.obs;

  showFilterOptions(){
    Get.bottomSheet(
        Obx((){
          return Container(
            height: 200.h,
            color: Colors.white,
            child: Column(
              children: [

                CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: filterByName.value,
                    title: const Text("Filter by name"),
                    onChanged: (v){
                      filterByName.value = !filterByName.value;
                    }
                ),

                CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: filterByName.value,
                    title: const Text("Filter by description"),
                    onChanged: (v){
                      filterByName.value = !filterByName.value;
                    }
                ),
              ],
            ),
          );
        })

    );
  }
}