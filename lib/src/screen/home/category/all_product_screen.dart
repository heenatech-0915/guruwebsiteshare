import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pagination_view/pagination_view.dart';
import 'package:cpcdiagnostics_ecommerce/src/controllers/home_screen_controller.dart';
import 'package:cpcdiagnostics_ecommerce/src/models/all_product_model.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/app_tags.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../servers/repository.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/category_product_card.dart';
import '../../../widgets/loader/shimmer_load_data.dart';
import '../../../widgets/loader/shimmer_products.dart';

class AllProductView extends StatefulWidget {
  const AllProductView({Key? key}) : super(key: key);

  @override
  State<AllProductView> createState() => _AllProductViewState();
}

class _AllProductViewState extends State<AllProductView> {

  final homeScreenContentController = Get.put(HomeScreenController());

  int page = 0;
  List<Data> filteredData = [];
  PaginationViewType paginationViewType = PaginationViewType.gridView;
  GlobalKey<PaginationViewState> key = GlobalKey<PaginationViewState>();
  TextEditingController searchTEC = TextEditingController();
  bool loadingFilteredData = false;
  RefreshController refreshController = RefreshController();
  List<Data> products = [];
  bool loading = false;

  //
   getData(int offset,{bool loading = false}) async {

    page++;
    setState(() {
      this.loading = loading;
    });
    return await Repository().getAllProduct(page: page).then((value){
      if(page==1){
        products = value;
      }
      else {
        products.addAll(value);
      }
      setState(() {
        this.loading = false;
        refreshController.loadComplete();
        if(page==1){
          refreshController.refreshCompleted();
        }
      });
    }).whenComplete((){
      setState(() {
        this.loading = false;
      });
    });
  }

  //
  getFilteredData() async {
    setState(() {
      loadingFilteredData = true;
    });
     await Repository().getFilteredProducts(
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

  //
  @override
  void initState() {
    super.initState();
    getData(page,loading: true);
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
            AppTags.allProduct.tr,
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
            AppTags.allProduct.tr,
            style: AppThemeData.headerTextStyle_14,
          ),
        ),
        body: Stack(
          children: [

            loading ? const Center(
              child: ShimmerProducts(),
            ) :
            searchTEC.text.isEmpty?
                Padding(
                  padding: EdgeInsets.only(top: 50.h),
                  child: SmartRefresher(
                    controller: refreshController,
                    enablePullUp: true,
                    enablePullDown: true,
                    onLoading: () {
                      getData(page);
                    },
                    onRefresh: (){
                      page = 0;
                      getData(page,loading: true);
                    },
                    child: GridView.builder(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                      ),
                      itemBuilder:
                          (BuildContext context, int index) {
                        return CategoryProductCard(
                          dataModel: products[index],
                          index: index,
                        );
                      },
                      itemCount: products.length,
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.w, vertical: 8.h),
                      shrinkWrap: true,
                    ),
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
                              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                              shrinkWrap: true,
                    ),
                  ),


            TextField(
              decoration:  const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  fillColor: Colors.white,
                  filled: true,
                  border: InputBorder.none,
                  hintText: "Search Products"
              ),
              controller: searchTEC,
              onChanged: _onSearchChanged,
            )],
        ));
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

}
