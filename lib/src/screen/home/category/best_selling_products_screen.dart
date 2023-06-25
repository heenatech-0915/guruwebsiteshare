import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pagination_view/pagination_view.dart';
import 'package:cpcdiagnostics_ecommerce/src/controllers/home_screen_controller.dart';
import 'package:cpcdiagnostics_ecommerce/src/models/best_selling_product_model.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/app_tags.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/app_theme_data.dart';
import 'package:flutter/material.dart';

import '../../../servers/repository.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/category_product_card.dart';
import '../../../widgets/loader/shimmer_load_data.dart';
import '../../../widgets/loader/shimmer_products.dart';

class BestSellingProductsView extends StatefulWidget {
  const BestSellingProductsView({Key? key}) : super(key: key);

  @override
  State<BestSellingProductsView> createState() =>
      _BestSellingProductsViewState();
}

class _BestSellingProductsViewState extends State<BestSellingProductsView> {
  final homeScreenContentController = Get.put(HomeScreenController());

  int page = 0;
  PaginationViewType paginationViewType = PaginationViewType.gridView;
  GlobalKey<PaginationViewState> key = GlobalKey<PaginationViewState>();
  TextEditingController searchTEC = TextEditingController();
  List<Data> filteredData = [];
  bool loadingFilteredData = false;

  Future<List<Data>> getData(int offset) async {
    //page = (offset / 1).round();
    page++;
    return await Repository().getBestSellingProduct(page: page);
  }

  getFilteredData() async {
    setState(() {
      loadingFilteredData = true;
    });
    await Repository().getBestSellFilteredProducts(
        search: searchTEC.text,
        sortByDesc: !homeScreenContentController.filterByName.value,
        filter: homeScreenContentController.filterValue.value
    ).then((value){
      setState(() {
        filteredData = value;
        loadingFilteredData = false;
      });
    }).whenComplete((){
      setState(() {
        loadingFilteredData = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    searchTEC.addListener(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isMobile(context)? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),

          onPressed: () {
            Get.back();
          }, // null disables the button
        ),
        centerTitle: true,
        title: Text(
          "Best Reagents",
          style: AppThemeData.headerTextStyle_16,
        ),
      ): AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60.h,
        leadingWidth: 40.w,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 25.r,
          ),

          onPressed: () {
            Get.back();
          }, // null disables the button
        ),
        centerTitle: true,
        title: Text(
          AppTags.bestSellingProduct.tr,
          style: AppThemeData.headerTextStyle_14,
        ),
      ),
      body: Stack(
        children: [
          searchTEC.text.isEmpty?Padding(
            padding: EdgeInsets.only(top: 60.h),
            child: PaginationView<Data>(
              key: key,
              paginationViewType: paginationViewType,
              pageFetch: getData,
              pullToRefresh: false,
              onError: (dynamic error) => Center(
                child: Text(AppTags.someErrorOccurred.tr),
              ),
              onEmpty: const Center(
                child: Text(AppTags.noProduct),
              ),
              bottomLoader: const Center(
                child: ShimmerLoadData(),
              ),
              initialLoader: const ShimmerProducts(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile(context)? 2:3,
                childAspectRatio: 0.68,
                mainAxisSpacing: isMobile(context)?15:20,
                crossAxisSpacing: isMobile(context)?15:20,
              ),
              itemBuilder: (BuildContext context, Data product, int index) {
                return CategoryProductCard(
                  dataModel: product,
                  index: index,
                );
              },
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
              shrinkWrap: true,
            ),
          ):loadingFilteredData
              ? const ShimmerProducts()
              : filteredData.isEmpty
                   ? const Text('No Products')
                   : Padding(
                        padding: EdgeInsets.only(top: 50.h),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return CategoryProductCard(
                              dataModel: filteredData[index],
                              index: index,
                            );
                          },
                          itemCount: filteredData.length,
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 8.h),
                          shrinkWrap: true,
                        ),
                    ),

          TextField(
            onChanged: _onSearchChanged,
            decoration:  InputDecoration(
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: InputBorder.none,
                hintText: "Search Products",
                suffixIcon: IconButton(
                    onPressed: (){
                      showFilter();
                    },
                    icon: const Icon(Icons.filter_alt)
                )
            ),
            controller: searchTEC,
          )

        ],
      ),
    );
  }

  Timer? _debounce;
  _onSearchChanged(String query) {
    if(query.isEmpty){
      page=0;
      return;
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      getFilteredData();
    });
  }

  showFilter(){
    Get.bottomSheet(
        Obx((){
          return Container(
            height: 200.h,
            color: Colors.white,
            child: Column(
              children: [

                CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: homeScreenContentController.filterValue.value==1,
                    title: const Text("Filter by name"),
                    onChanged: (v){
                      homeScreenContentController.filterValue.value = 1;
                    }
                ),

                CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: homeScreenContentController.filterValue.value==0,
                    title: const Text("Filter by description"),
                    onChanged: (v){
                      homeScreenContentController.filterValue.value = 0;
                    }
                ),

                CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: homeScreenContentController.filterValue.value==2,
                    title: const Text("Filter by sku"),
                    onChanged: (v){
                      homeScreenContentController.filterValue.value =2;
                    }
                ),
              ],
            ),
          );
        })

    );
  }

}
