import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/product_by_category_model.dart';

class RelatedReagentsController extends GetxController{


  RelatedReagentsController({List<CategoryProductData> ?reagentsData}){
    getFilterItems();
  }

  RxList<CategoryProductData> allProducts        = <CategoryProductData>[].obs;
  RxList<CategoryProductData> filteredData       = <CategoryProductData>[].obs;
  RxList<CategoryProductData> searchFilteredData = <CategoryProductData>[].obs;


  RxList<String> brandFilters             = <String>[].obs;
  RxList<String> parameterFilters         = <String>[].obs;
  RxList<String> selectedBrandFilters     = <String>[].obs;
  RxList<String> selectedParameterFilters = <String>[].obs;
  RxBool showParameterFilters = false.obs;
  RxBool showBrandFilters     = false.obs;

  //
  getFilterItems(){

    allProducts.value.sort((a, b) {
      return a.tags!.toLowerCase().compareTo(b.tags!.toLowerCase());
    });
    for (var value in allProducts) {
      if(value.ordering==2){
        if(value.brand!.isNotEmpty && !brandFilters.contains(value.brand)) {
          brandFilters.add(value.brand!);
        }
        if(value.tags!.isNotEmpty && !parameterFilters.contains(value.tags)){
          parameterFilters.add(value.tags!);
        }
      }
    }
    brandFilters.toSet().toList();
    parameterFilters.toSet().toList();
  }

  //
  filterReagents(){

    filteredData.value = [];
    if(selectedBrandFilters.isNotEmpty){
      for (var brand in selectedBrandFilters) {
        if(selectedParameterFilters.isNotEmpty) {
          allProducts.where((v) => v.ordering == 2).toList().forEach((element) {
            if (element.brand == brand &&
                (selectedParameterFilters.contains(element.tags))) {
              filteredData.add(element);
            }
          });
        }
        else{
          allProducts.where((v) => v.ordering == 2).toList().forEach((element) {
            if (element.brand == brand) {
              filteredData.add(element);
            }
          });
        }
      }
    }
    //only parameter filter
    else if(selectedParameterFilters.isNotEmpty){
      allProducts.where((v) => v.ordering == 2).toList().forEach((element) {
        if (selectedParameterFilters.contains(element.tags)) {
          filteredData.add(element);
        }
      });
    }
    print("selected brands-->$selectedBrandFilters");
    print("selected parameters-->$selectedParameterFilters");
    for (var element in filteredData) {
      print("Parameter-->${element.tags}");
      print("Brand-->${element.brand}");
    }
  }

  //
  searchProducts(String search){

    searchFilteredData.value = [];
    String query = search.toLowerCase();

    if(filteredData.isNotEmpty){
      for (var element in filteredData) {
        if(element.title!=null && element.title!.toLowerCase().contains(query)){
          if(!searchFilteredData.contains(element)) {
            searchFilteredData.add(element);
          }
        }
        if(element.shortDescription!=null && element.shortDescription!.toLowerCase().contains(query)){
          if(!searchFilteredData.contains(element)) {
            searchFilteredData.add(element);
          }
        }
        if(element.sku!=null && element.sku!.toLowerCase().contains(query)){
          if(!searchFilteredData.contains(element)) {
            searchFilteredData.add(element);
          }
        }
      }
    }
    else if(allProducts.isNotEmpty){
      for (var element in allProducts) {
        if(element.title!=null && element.title!.toLowerCase().contains(query)){
          if(!searchFilteredData.contains(element)) {
            searchFilteredData.add(element);
          }
        }
        if(element.shortDescription!=null && element.shortDescription!.toLowerCase().contains(query)){
          if(!searchFilteredData.contains(element)) {
            searchFilteredData.add(element);
          }
        }
        if(element.sku!=null && element.sku!.toLowerCase().contains(query)){
          if(!searchFilteredData.contains(element)) {
            searchFilteredData.add(element);
          }
        }
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    allProducts.stream.listen((event) {
      getFilterItems();
    });
  }
}