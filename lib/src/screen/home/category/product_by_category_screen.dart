import 'dart:async';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pagination_view/pagination_view.dart';
import 'package:cpcdiagnostics_ecommerce/src/controllers/home_screen_controller.dart';
import 'package:cpcdiagnostics_ecommerce/src/models/product_by_category_model.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:cpcdiagnostics_ecommerce/src/utils/responsive.dart';
import 'package:cpcdiagnostics_ecommerce/src/widgets/category_product_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../controllers/products_filter_controller.dart';
import '../../../widgets/loader/shimmer_products.dart';

class ProductByCategory extends StatefulWidget {
   ProductByCategory({
    Key? key,
    required this.id,
    this.title,
    this.subtitle=''
  }) : super(key: key);
  final int? id;
  final String? title;
  String? subtitle;

  @override
  State<ProductByCategory> createState() => _ProductByCategoryState();
}

class _ProductByCategoryState extends State<ProductByCategory> {

  final homeController = Get.put(HomeScreenController());
  late ProductsFilterController fc;
  int page = 0;
  GlobalKey<PaginationViewState> key = GlobalKey<PaginationViewState>();
  late List<CategoryProductData> data = [];
  TextEditingController searchTEC = TextEditingController();
  List<CategoryProductData> filteredData = [];
  bool loadingFilteredData = false;

  @override
  void initState() {
    super.initState();
    fc = Get.put(ProductsFilterController(categoryId: widget.id!,title: widget.title!,subtitle: widget.subtitle!));
    if(widget.subtitle=="Instruments"){
      fc.mainFilterType.value=1;
    }
    else if(widget.subtitle=="Reagents"){
      fc.mainFilterType.value=2;
    }
    if(widget.id==7){
      fc.mainFilterType.value = 2;
    }
  }

  @override
  void dispose() {
    Get.delete<ProductsFilterController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
       /*return Get.delete<ProductsFilterController>().then((value){
          return Future.value(true);
        }).whenComplete((){
          return Future.value(true);
        });*/
        return Future.value(true);
      },
      child: Scaffold(
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
              },
            ),
            centerTitle: true,
            title: Text(
              widget.title.toString(),
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
              widget.title.toString(),
              style: AppThemeData.headerTextStyle_14,
            ),
          ),
          body: Obx((){
            return Stack(
              children: [

                fc.isFiltering.value
                    ? Padding(
                        padding: EdgeInsets.only(top: 170.h),
                        child: const ShimmerProducts(),
                      )
                    : fc.searchFilteredData.isNotEmpty && fc.mainFilterType.value==1
                    ? Padding(
                            padding: EdgeInsets.only(top: 200.h),
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return CategoryProductCard(
                                  dataModel: fc.searchFilteredData[index],
                                  index: index,
                                  categoryId: widget.id!,
                                );
                              },
                              itemCount: fc.searchFilteredData.length,
                              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                              shrinkWrap: true,
                            ),
                          ):
                fc.filteredData.isNotEmpty && fc.mainFilterType.value == 1
                    ? Padding(
                            padding: EdgeInsets.only(top: 200.h),
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return CategoryProductCard(
                                  dataModel: fc.filteredData[index],
                                  index: index,
                                  categoryId: widget.id!,
                                );
                              },
                              itemCount: fc.filteredData.length,
                              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                              shrinkWrap: true,
                            ),
                          )
                     : fc.mainFilterType.value == 2 && fc.keyWord.isNotEmpty && fc.reagentsSearchFilteredData.isEmpty
                     ?  const Center(child: Text('Search do not match any products'))
                     : fc.mainFilterType.value == 2 && fc.keyWord.isNotEmpty && fc.reagentsSearchFilteredData.isNotEmpty
                     ? Padding(
                                            padding:
                                                EdgeInsets.only(top: 200.h),
                                            child: GridView.builder(
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                    childAspectRatio: 0.85,
                                                mainAxisSpacing: 15,
                                                crossAxisSpacing: 15,
                                              ),
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return CategoryProductCard(
                                                  dataModel:
                                                      fc.reagentsSearchFilteredData[
                                                          index],
                                                  index: index,
                                  categoryId: widget.id!,
                                                );
                                              },
                                              itemCount: fc
                                                  .reagentsSearchFilteredData.length,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15.w,
                                                  vertical: 8.h),
                                              shrinkWrap: true,
                                            ),
                                          )
                    : fc.mainFilterType.value == 2 && fc.filterCheck() && fc.reagentsFilteredData.isEmpty
                    ? const Center(child: Text('No matching products'))
                                        : fc.mainFilterType.value==2 && fc.reagentsFilteredData.isNotEmpty
                        ? Padding(
                                    padding: EdgeInsets.only(top: 200.h),
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 1.5,
                                        mainAxisSpacing: 15,
                                        crossAxisSpacing: 15,
                                      ),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return CategoryProductCard(
                                          dataModel:
                                              fc.reagentsFilteredData[index],
                                          index: index,
                                  categoryId: widget.id!,
                                        );
                                      },
                                      itemCount: fc.reagentsFilteredData.length,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.w, vertical: 8.h),
                                      shrinkWrap: true,
                                    ),
                                  )
                                : fc.instruments.isNotEmpty && fc.mainFilterType.value == 1
                        ? Padding(
                            padding: EdgeInsets.only(top: 200.h),
                            child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return CategoryProductCard(
                                  dataModel: fc.searchFilteredData.isNotEmpty?fc.searchFilteredData[index]:fc.instruments[index],
                                  index: index,
                                  categoryId: widget.id!,
                                );
                              },
                              itemCount: fc.searchFilteredData.isNotEmpty?fc.searchFilteredData.length:fc.instruments.length,
                              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                              shrinkWrap: true,
                            ),
                          )
                        : fc.reagents.isNotEmpty && fc.mainFilterType.value == 2
                            ? Padding(
                                padding: EdgeInsets.only(top: 200.h),
                                child: SmartRefresher(
                                  controller: fc.refreshController,
                                  enablePullUp: true,
                                  enablePullDown: false,
                                  onLoading: () {
                                    if(fc.selectedBrandFilters.isNotEmpty || fc.selectedParameterFilters.isNotEmpty
                                           || fc.selectedProductFilters.isNotEmpty){
                                      return;
                                    }
                                    fc.getFilteredProducts();
                                  },
                                  child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 1.5,
                                      mainAxisSpacing: 15,
                                      crossAxisSpacing: 15,
                                    ),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return CategoryProductCard(
                                        dataModel: fc.reagents[index],
                                        index: index,
                                  categoryId: widget.id!,
                                      );
                                    },
                                    itemCount: fc.reagents.length,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.w, vertical: 8.h),
                                    shrinkWrap: true,
                                  ),
                                ),
                              )
                            : const Center(child: Text('No products')),


                (fc.instruments.isNotEmpty || fc.reagents.isNotEmpty)
                   && fc.mainFilterType.value==2 && !fc.isFiltering.value
                    ? Positioned(
                        top: 130.h,
                        left: MediaQuery.of(context).size.width - 160.w,
                        child: Container(
                          width: 120.w,
                          height: 35.h,
                          margin: EdgeInsets.only(left: 20.w),
                          padding: EdgeInsets.only(left: 7.w),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(1,1),
                                color: Colors.black12,
                                blurRadius: 4
                              )
                            ]
                          ),
                          child: InkWell(
                            onTap: () {
                              showReagentsFilterBottomsheet();
                            },
                            child: Row(
                              children: const [
                                Icon(
                                    Icons.filter_alt,
                                    color: Colors.grey
                                ),
                                Expanded(
                                    child: Text(
                                      'Filter',
                                      style: TextStyle(
                                          color: Colors.grey
                                      )
                                    )
                                ),
                                Icon(
                                    Icons.arrow_drop_down_outlined,
                                    color: Colors.grey
                                )
                              ],
                            ),
                          ),
                        )
                 ):const SizedBox(),

                (fc.instruments.isNotEmpty || fc.reagents.isNotEmpty)
                   && (fc.mainFilterType.value==1 && (fc.instrumentFilters.isNotEmpty || fc.immunologyInstrumentFilters.isNotEmpty))
                    ? Positioned(
                        top: 130.h,
                        left: MediaQuery.of(context).size.width - 160.w,
                        child: Container(
                          width: 120.w,
                          height: 35.h,
                          margin: EdgeInsets.only(left: 20.w),
                          padding: EdgeInsets.only(left: 7.w),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(1,1),
                                color: Colors.black12,
                                blurRadius: 4
                              )
                            ]
                          ),
                          child: InkWell(
                            onTap: () {
                              showReagentsFilterBottomsheet();
                            },
                            child: Row(
                              children: const [
                                Icon(
                                    Icons.filter_alt,
                                    color: Colors.grey
                                ),
                                Expanded(
                                    child: Text(
                                      'Filter',
                                      style: TextStyle(
                                          color: Colors.grey
                                      )
                                    )
                                ),
                                Icon(
                                    Icons.arrow_drop_down_outlined,
                                    color: Colors.grey
                                )
                              ],
                            ),
                          ),
                        )
                 ):const SizedBox(),

             Positioned(
                    top: 50.h,
                    child: Obx((){
                      return Container(
                        width: widget.id==7||widget.id==6?MediaQuery.of(context).size.width/2:MediaQuery.of(context).size.width,
                        height: 65.h,
                        decoration: const BoxDecoration(
                            color: Colors.white
                        ),
                        child: widget.id == 7
                            ? InkWell(
                                onTap: () {
                                  if (fc.isFiltering.value) {
                                    return;
                                  }
                                  fc.mainFilterType.value = 2;
                                  widget.subtitle = "";
                                  if (fc.reagents.isEmpty) {
                                    fc.getFilteredProducts();
                                    return;
                                  }
                                  fc.filterReagents();
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  decoration: BoxDecoration(
                                    color: fc.mainFilterType.value == 2 ||
                                            widget.subtitle == "Reagents"
                                        ? AppThemeData.primaryColor
                                        : Colors.white,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Reagents',
                                      style: TextStyle(
                                          color: fc.mainFilterType.value == 2
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                ),
                              )
                            : widget.id == 6
                                ? InkWell(
                                    onTap: () {
                                      if (fc.isFiltering.value) {
                                        return;
                                      }
                                      fc.mainFilterType.value = 1;
                                      widget.subtitle = "";
                                      if (fc.instruments.isEmpty) {
                                        fc.getFilteredProducts();
                                        return;
                                      }
                                      if (widget.title == "Immunology") {
                                        fc.immunologyInstrumentsFilter();
                                      } else {
                                        fc.filterInstruments();
                                      }
                                      fc.searchFilteredData.clear();
                                    },
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      decoration: BoxDecoration(
                                        color: fc.mainFilterType.value == 1 ||
                                                widget.subtitle == "Instruments"
                                            ? AppThemeData.primaryColor
                                            : Colors.white,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Instruments',
                                          style: TextStyle(
                                              color:
                                                  fc.mainFilterType.value == 1
                                                      ? Colors.white
                                                      : Colors.black),
                                        ),
                                      ),
                                    ),
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (fc.isFiltering.value) {
                                            return;
                                          }
                                          fc.mainFilterType.value = 1;
                                          widget.subtitle = "";
                                          if (fc.instruments.isEmpty) {
                                            fc.getFilteredProducts();
                                            return;
                                          }
                                          if (widget.title == "Immunology") {
                                            fc.immunologyInstrumentsFilter();
                                          } else {
                                            fc.filterInstruments();
                                          }
                                          fc.searchFilteredData.clear();
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          decoration: BoxDecoration(
                                            color:
                                                fc.mainFilterType.value == 1 ||
                                                        widget.subtitle ==
                                                            "Instruments"
                                                    ? AppThemeData.primaryColor
                                                    : Colors.white,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Instruments',
                                              style: TextStyle(
                                                  color:
                                                      fc.mainFilterType.value ==
                                                              1
                                                          ? Colors.white
                                                          : Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (fc.isFiltering.value) {
                                            return;
                                          }
                                          fc.mainFilterType.value = 2;
                                          widget.subtitle = "";
                                          if (fc.reagents.isEmpty) {
                                            fc.getFilteredProducts();
                                            return;
                                          }
                                          fc.filterReagents();
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          decoration: BoxDecoration(
                                            color:
                                                fc.mainFilterType.value == 2 ||
                                                        widget.subtitle ==
                                                            "Reagents"
                                                    ? AppThemeData.primaryColor
                                                    : Colors.white,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Reagents',
                                              style: TextStyle(
                                                  color:
                                                      fc.mainFilterType.value ==
                                                              2
                                                          ? Colors.white
                                                          : Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                      );
                    })
                ),

                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextField(
                      onChanged:_onSearchChanged,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        fillColor: Colors.white,
                        filled: true,
                        border: InputBorder.none,
                        hintText: "Search Products",
                      ),
                      controller: searchTEC,
                    ),
                  ],
                ),
              ],
            );
          })
      ),
    );
  }

  Timer? _debounce;

  //
  _onSearchChanged(String query) {

    if(query.isEmpty && fc.mainFilterType.value==1){
       fc.searchFilteredData.value = [];
      _debounce?.cancel();
      return;
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      fc.keyWord = query;
      if(fc.mainFilterType.value==2){
        if(query.isEmpty && fc.filterCheck()){
          fc.reagentsSearchFilteredData.clear();
          return;
        }
        fc.getFilteredProducts(query:query);
        return;
      }
      fc.searchProducts(query);
    });
  }

  //
  showReagentsFilterBottomsheet(){

    fc.tempProductFilters = fc.selectedProductFilters;
    fc.tempBrandFilters = fc.selectedBrandFilters;
    fc.tempParameterFilters = fc.selectedParameterFilters;

    showModalBottomSheet<dynamic>(
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
        ),
        context: context, builder: (BuildContext context) {
      return  fc.mainFilterType.value==2?WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: SizedBox(
          width: 400.w,
          height: MediaQuery.of(context).size.height*0.9,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h,left: 20.w,right: 20.w,bottom: 60.h),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(height: 20.h),

                      const Center(
                        child: Text(
                          "Filter Reagents",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),

                      SizedBox(height: 30.h),

                      fc.productFilters.isNotEmpty?DropdownButton2(
                          dropdownMaxHeight: 300.h,
                          scrollbarAlwaysShow: true,
                          scrollbarRadius: const Radius.circular(10),
                          isExpanded: true,
                          scrollbarThickness: 5,
                          isDense: true,
                          hint: const Text("Choose Instruments"),
                          items: fc.productFilters.map((element){
                            return DropdownMenuItem<String>(
                                value: element,
                                child: Obx((){
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 300.w),
                                    child: CheckboxListTile(
                                        controlAffinity: ListTileControlAffinity.leading,
                                        value: fc.selectedProductFilters.contains(element),
                                        title: Text(element!),
                                        onChanged: (v) {
                                          fc.filtersChanged.value = true;
                                          if(fc.selectedProductFilters.contains(element)){
                                              fc.selectedProductFilters.remove(element);
                                            if(fc.selectedProductFilters.isEmpty && fc.selectedParameterFilters.isEmpty && fc.selectedBrandFilters.isEmpty){
                                              fc.filteredData.value = [];
                                            }
                                            return;
                                          }
                                          fc.selectedProductFilters.add(element);
                                          //fc.filterReagents();
                                        }),
                                  );
                                })
                            );
                          }).toList(),
                          onChanged: (v){
                            fc.filtersChanged.value = true;
                            if(fc.selectedProductFilters.contains(v)){
                              fc.selectedProductFilters.remove(v);
                              return;
                            }
                            fc.selectedProductFilters.add(v.toString());
                          }
                      ):const SizedBox(),

                      SizedBox(height: 50.h),

                      DropdownButton2(
                          dropdownMaxHeight: 300.h,
                          scrollbarAlwaysShow: true,
                          scrollbarRadius: const Radius.circular(10),
                          isExpanded: true,
                          scrollbarThickness: 5,
                          isDense: true,
                          hint: const Text("Choose Brands"),
                          items: fc.brandFilters.map((element){
                            return DropdownMenuItem<String>(
                                value: element,
                                child: Obx((){
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 300.w),
                                    child: CheckboxListTile(
                                        controlAffinity: ListTileControlAffinity.leading,
                                        value: fc.selectedBrandFilters.contains(element),
                                        title: Text(element),
                                        onChanged: (v) {
                                          fc.filtersChanged.value = true;
                                          if(fc.selectedBrandFilters.contains(element)){
                                              fc.selectedBrandFilters.remove(element);
                                            if(fc.selectedProductFilters.isEmpty && fc.selectedParameterFilters.isEmpty && fc.selectedBrandFilters.isEmpty){
                                              fc.filteredData.value = [];
                                            }
                                            return;
                                          }
                                          fc.selectedBrandFilters.add(element);
                                         // fc.filterReagents();
                                        }),
                                  );
                                })
                            );
                          }).toList(),
                          onChanged: (v){
                            fc.filtersChanged.value = true;
                            if(fc.selectedBrandFilters.contains(v)){
                              fc.selectedBrandFilters.remove(v);
                              return;
                            }
                            fc.selectedBrandFilters.add(v.toString());
                          }
                      ),

                      SizedBox(height: 50.h),

                      DropdownButton2(
                          dropdownMaxHeight: 300.h,
                          scrollbarAlwaysShow: true,
                          scrollbarRadius: const Radius.circular(10),
                          isExpanded: true,
                          scrollbarThickness: 5,
                          hint: const Text("Choose Parameters"),
                          items: fc.parameterFilters.map((element){
                            return DropdownMenuItem<String>(
                                value: element,
                                child: Obx((){
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 300.w),
                                    child: CheckboxListTile(
                                        controlAffinity: ListTileControlAffinity.leading,
                                        value: fc.selectedParameterFilters.contains(element),
                                        title: Text(element),
                                        onChanged: (v) {
                                          fc.filtersChanged.value = true;
                                          if(fc.selectedParameterFilters.contains(element)){
                                            fc.selectedParameterFilters.remove(element);
                                            if(fc.selectedProductFilters.isEmpty && fc.selectedParameterFilters.isEmpty && fc.selectedBrandFilters.isEmpty){
                                              fc.filteredData.value = [];
                                            }
                                            return;
                                          }
                                          fc.selectedParameterFilters.add(element);
                                          //fc.filterReagents();
                                        }),
                                  );
                                })
                            );
                          }).toList(),
                          onChanged: (v){
                            fc.filtersChanged.value = true;
                            if(fc.selectedParameterFilters.contains(v)){
                              fc.selectedParameterFilters.remove(v);
                              return;
                            }
                            fc.selectedParameterFilters.add(v.toString());
                            fc.filterReagents();
                          }
                      ),

                      SizedBox(height: 50.h),

                      Obx((){
                        return fc.selectedProductFilters.isNotEmpty
                            ? const Text(
                          "Chosen Products",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                          ),
                        )
                            : const SizedBox();
                      }) ,

                      SizedBox(height: 15.h),

                      Obx((){
                        return Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: fc.selectedProductFilters.map((element){
                            return InkWell(
                              onTap: (){
                                fc.filtersChanged.value = true;
                                fc.selectedProductFilters.remove(element);
                                if(fc.selectedProductFilters.isEmpty && fc.selectedParameterFilters.isEmpty && fc.selectedBrandFilters.isEmpty){
                                    fc.processFilter(ordering: 2);
                                    return;
                                }
                                fc.filterReagents();
                              },
                              child: Container(
                                width: 100.w,
                                height: 50.h,
                                padding: EdgeInsets.all(7.w),
                                decoration: BoxDecoration(
                                    color: AppThemeData.primaryColor.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(7)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      flex:2,
                                      child: Text(
                                        element,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const Expanded(
                                        child: Icon(
                                            Icons.close,
                                            size: 13,
                                            color: Colors.white
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),


                      Obx((){
                        return fc.selectedBrandFilters.isNotEmpty
                            ? const Text(
                          "Chosen Brands",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                          ),
                        )
                            : const SizedBox();
                      }) ,

                      SizedBox(height: 15.h),

                      Obx((){
                        return Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: fc.selectedBrandFilters.map((element){
                            return InkWell(
                              onTap: (){
                                fc.filtersChanged.value = true;
                                fc.selectedBrandFilters.remove(element);
                              },
                              child: Container(
                                width: 100.w,
                                height: 50.h,
                                padding: EdgeInsets.all(7.w),
                                decoration: BoxDecoration(
                                    color: AppThemeData.primaryColor.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(7)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      flex:2,
                                      child: Text(
                                        element,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const Expanded(
                                        child: Icon(
                                            Icons.close,
                                            size: 13,
                                            color: Colors.white
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),

                      SizedBox(height: 15.h),

                      Obx((){
                        return fc.selectedParameterFilters.isNotEmpty
                            ? const Text(
                          "Chosen Parameters",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                          ),
                        )
                            : const SizedBox();
                      }),

                      SizedBox(height: 15.h),

                      Obx((){
                        return Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: fc.selectedParameterFilters.map((element){
                            return InkWell(
                              onTap: (){
                                fc.filtersChanged.value = true;
                                fc.selectedParameterFilters.remove(element);
                              },
                              child: Container(
                                width: 100.w,
                                height: 50.h,
                                padding: EdgeInsets.all(7.w),
                                decoration: BoxDecoration(
                                    color: AppThemeData.primaryColor.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(7)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      flex:2,
                                      child: Text(
                                        element,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const Expanded(child: Icon(Icons.close,size: 13,color: Colors.white,)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),

                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 0.h,
                child: Center(
                  child: InkWell(
                    onTap: (){
                      searchTEC.text = "";
                      if(!fc.filterCheck()){
                        fc.reagentsFilteredData.clear();
                        Navigator.pop(context);
                        return;
                      }
                      if( fc.filtersChanged.value) {
                        fc.getFilteredProducts();
                      }
                      fc.filtersChanged.value = false;
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50.h,
                      decoration: BoxDecoration(
                          color: AppThemeData.primaryColor,
                          boxShadow: const [
                            BoxShadow(
                                offset: Offset(1,1),
                                blurRadius: 3,
                                color: Colors.black12
                            )
                          ]
                      ),
                      child: const Center(
                        child: Text(
                          'Done',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      )
      : widget.title == "Immunology"? Obx((){
        return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [

                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                      'Instruments Filter',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      )
                  ),
                ),

                const Divider(
                  color: Colors.black,
                  thickness: 2,
                ),

                SizedBox(height: 30.h),

                Wrap(
                  alignment: WrapAlignment.start,
                  runSpacing: 10.h,
                  spacing: 10.w,
                  children: fc.immunologyInstrumentFilters.map((e){
                    bool selected = fc.selectedImmunologyInstrumentFilters.contains(e);
                    return InkWell(
                      onTap: (){
                        if (fc.selectedImmunologyInstrumentFilters.contains(e)) {
                          fc.selectedImmunologyInstrumentFilters.remove(e);
                          fc.immunologyInstrumentsFilter();
                          return;
                        }
                        fc.selectedImmunologyInstrumentFilters.add(e);
                        fc.immunologyInstrumentsFilter();
                      },
                      child: Container(
                        height: 50.h,
                        width: 140.w,
                        padding: EdgeInsets.symmetric(horizontal: 5.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: selected?AppThemeData.primaryColor:Colors.grey.shade400,
                          border: Border.all(
                              color: selected?AppThemeData.primaryColor.withOpacity(0.4):Colors.grey,
                              width: selected?4:0.5
                          )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            selected
                                ? const Expanded(
                                child: Icon(
                                  Icons.check,
                                  size: 17,
                                  color: Colors.white,
                                ))
                                : const SizedBox(),

                            SizedBox(width: 10.w),

                            Expanded(
                              flex:3,
                              child: Text(
                                e,
                                style: const TextStyle(
                                    color: Colors.white,
                                   fontSize: 12
                                )
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 60.h,
                        decoration: BoxDecoration(
                            color: AppThemeData.primaryColor,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)
                            ),
                            boxShadow: const [
                              BoxShadow(
                                  offset: Offset(1,1),
                                  blurRadius: 3,
                                  color: Colors.black12
                              )
                            ]
                        ),
                        child: const Center(
                          child: Text(
                            'Filter',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
        );
      })
                  : Obx(() {
                    return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('Instruments Filter',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),

                            const Divider(
                              color: Colors.black,
                              thickness: 2,
                            ),

                            SizedBox(height: 30.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.h),
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                runSpacing: 10.h,
                                spacing: 10.w,
                                children: fc.instrumentFilters.map((e) {
                                  bool selected = fc.selectedInstrumentFilters
                                      .contains(e);
                                  return InkWell(
                                    onTap: () {
                                      if (fc.selectedInstrumentFilters
                                          .contains(e)) {
                                        fc.selectedInstrumentFilters
                                            .remove(e);
                                        fc.filterInstruments();
                                        return;
                                      }
                                      fc.selectedInstrumentFilters.add(e);
                                      fc.filterInstruments();
                                    },
                                    child: Container(
                                      height: 50.h,
                                      width: 140.w,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: selected
                                              ? AppThemeData.primaryColor
                                              : Colors.grey.shade400,
                                          border: Border.all(
                                              color: selected
                                                  ? AppThemeData.primaryColor
                                                      .withOpacity(0.4)
                                                  : Colors.grey,
                                              width: selected ? 4 : 0.5)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          selected
                                              ? const Expanded(
                                                  child: Icon(
                                                  Icons.check,
                                                  size: 17,
                                                  color: Colors.white,
                                                ))
                                              : const SizedBox(),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            flex: 3,
                                            child: Text(e,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 60.h,
                                    decoration: BoxDecoration(
                                        color: AppThemeData.primaryColor,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10)),
                                        boxShadow: const [
                                          BoxShadow(
                                              offset: Offset(1, 1),
                                              blurRadius: 3,
                                              color: Colors.black12)
                                        ]),
                                    child: const Center(
                                      child: Text(
                                        'Filter',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ));
                  });
    }
    );
  }
}
