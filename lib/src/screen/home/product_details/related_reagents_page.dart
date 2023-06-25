import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controllers/related_reagents_controller.dart';
import '../../../models/product_by_category_model.dart';
import '../../../utils/app_theme_data.dart';
import '../../../widgets/category_product_card.dart';

class RelatedReagentsPage extends StatefulWidget {
  RelatedReagentsPage(
      {Key? key, this.title = '', this.relatedReagents = const []})
      : super(key: key);

  String title;
  List<CategoryProductData> relatedReagents;

  @override
  State<RelatedReagentsPage> createState() => _RelatedReagentsPageState();
}

class _RelatedReagentsPageState extends State<RelatedReagentsPage> {
  late RelatedReagentsController vc = Get.put(RelatedReagentsController());
  TextEditingController searchTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    vc.allProducts.value = widget.relatedReagents;
  }

  @override
  Widget build(BuildContext context) {
    vc.allProducts.forEach((element) {
      print(element);
    });
    return Scaffold(
        appBar: AppBar(
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
            'Related Reagents',
            style: AppThemeData.headerTextStyle_16,
          ),
        ),
        body: Obx(() {
          return Column(
            children: [
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      border: InputBorder.none,
                      hintText: "Search Products",
                    ),
                    controller: searchTEC,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 30.w),
                    child: GestureDetector(
                      onTap: () {
                        showReagentsFilterBottomsheet();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.filter_alt),
                          Container(
                            width: 70.w,
                            height: 45.h,
                            decoration: const BoxDecoration(),
                            child: const Center(
                              child: Text('Filter By'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: vc.searchFilteredData.isNotEmpty
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return CategoryProductCard(
                              dataModel: vc.searchFilteredData[index],
                              index: index,
                            );
                          },
                          itemCount: vc.searchFilteredData.length,
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 8.h),
                          shrinkWrap: true,
                        )
                      : vc.filteredData.isNotEmpty
                          ? GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.68,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return CategoryProductCard(
                                  dataModel: vc.filteredData[index],
                                  index: index,
                                );
                              },
                              itemCount: vc.filteredData.length,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 8.h),
                              shrinkWrap: true,
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.29,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                print(index);
                                return CategoryProductCard(
                                  dataModel: vc.allProducts[index],
                                  index: index,
                                );
                              },
                              itemCount: vc.allProducts.length,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 8.h),
                              shrinkWrap: true,
                            ))
            ],
          );
        }));
  }

  showReagentsFilterBottomsheet() {
    showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            width: 400.w,
            height: MediaQuery.of(context).size.height * 0.9,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(25.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    const Center(
                      child: Text(
                        "Filter Reagents",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 50.h),
                    DropdownButton(
                        hint: const Text("Choose Parameters"),
                        items: vc.parameterFilters.map((element) {
                          return DropdownMenuItem<String>(
                              value: element,
                              child: Obx(() {
                                return ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child: CheckboxListTile(
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: vc.selectedParameterFilters
                                          .contains(element),
                                      title: Text(element),
                                      onChanged: (v) {
                                        if (vc.selectedParameterFilters
                                            .contains(element)) {
                                          vc.selectedParameterFilters
                                              .remove(element);
                                          return;
                                        }
                                        vc.selectedParameterFilters
                                            .add(element);
                                        vc.filterReagents();
                                      }),
                                );
                              }));
                        }).toList(),
                        onChanged: (v) {
                          if (vc.selectedParameterFilters.contains(v)) {
                            vc.selectedParameterFilters.remove(v);
                            return;
                          }
                          vc.selectedParameterFilters.add(v.toString());
                          vc.filterReagents();
                        }),
                    SizedBox(height: 50.h),
                    Obx(() {
                      return vc.selectedBrandFilters.isNotEmpty
                          ? const Text(
                              "Chosen Brands",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          : const SizedBox();
                    }),
                    SizedBox(height: 15.h),
                    Obx(() {
                      return Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: vc.selectedBrandFilters.map((element) {
                          return InkWell(
                            onTap: () {
                              vc.selectedBrandFilters.remove(element);
                              if (vc.selectedParameterFilters.isEmpty &&
                                  vc.selectedBrandFilters.isEmpty) {
                                vc.filteredData.value = [];
                                return;
                              }
                              vc.filterReagents();
                            },
                            child: Container(
                              width: 100.w,
                              height: 50.h,
                              padding: EdgeInsets.all(7.w),
                              decoration: BoxDecoration(
                                  color: AppThemeData.primaryColor
                                      .withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(7)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      element,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const Expanded(
                                      child: Icon(Icons.close,
                                          size: 13, color: Colors.white)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    SizedBox(height: 15.h),
                    Obx(() {
                      return vc.selectedParameterFilters.isNotEmpty
                          ? const Text(
                              "Chosen Parameters",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          : const SizedBox();
                    }),
                    SizedBox(height: 15.h),
                    Obx(() {
                      return Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: vc.selectedParameterFilters.map((element) {
                          return InkWell(
                            onTap: () {
                              vc.selectedParameterFilters.remove(element);
                              if (vc.selectedParameterFilters.isEmpty &&
                                  vc.selectedBrandFilters.isEmpty) {
                                vc.filteredData.value = [];
                                return;
                              }
                              vc.filterReagents();
                            },
                            child: Container(
                              width: 100.w,
                              height: 50.h,
                              padding: EdgeInsets.all(7.w),
                              decoration: BoxDecoration(
                                  color: AppThemeData.primaryColor
                                      .withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(7)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      element,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const Expanded(
                                      child: Icon(
                                    Icons.close,
                                    size: 13,
                                    color: Colors.white,
                                  )),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    SizedBox(height: 50.h),
                    Center(
                      child: InkWell(
                        onTap: () {
                          if (vc.selectedParameterFilters.isNotEmpty ||
                              vc.selectedBrandFilters.isNotEmpty) {
                            vc.filterReagents();
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 120.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                              color: AppThemeData.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                    color: Colors.black12)
                              ]),
                          child: const Center(
                            child: Text(
                              'Done',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Timer? _debounce;
  _onSearchChanged(String query) {
    if (query.isEmpty) {
      vc.searchFilteredData.value = [];
      _debounce?.cancel();
      return;
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      vc.searchProducts(query);
    });
  }
}
