import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/product_by_category_model.dart';
import '../servers/repository.dart';

class ProductsFilterController extends GetxController{

  ProductsFilterController({
    this.categoryId =0,
    this.title="",
    this.subtitle=""
  });

  RxInt  mainFilterType   = 1.obs;
  RxBool isFiltering      = false.obs;
  RxList immunologySubFilterList = [3,4,5].obs;
  RxList reagentSubFilterList    = [].obs;
  RxBool showReagentsFilter      = false.obs;
  RxBool filtersChanged          = false.obs;
  RxList<CategoryProductData> allProducts        = <CategoryProductData>[].obs;
  RxList<CategoryProductData> filteredData       = <CategoryProductData>[].obs;
  RxList<CategoryProductData> reagentsFilteredData       = <CategoryProductData>[].obs;
  RxList<CategoryProductData> reagentsSearchFilteredData = <CategoryProductData>[].obs;
  RxList<CategoryProductData> searchFilteredData = <CategoryProductData>[].obs;
  RxList<CategoryProductData> instruments        = <CategoryProductData>[].obs;
  RxList<CategoryProductData> reagents           = <CategoryProductData>[].obs;
  RxBool showingFilteredData = false.obs;
  String title    = '';
  String subtitle = "";
  int categoryId  = 0;
  int pageIndex   = 0;
  String keyWord  = "";


  RxList<String?> productFilters     = <String>[].obs;
  RxList<String>  brandFilters       = <String>[].obs;
  RxList<String>  parameterFilters   = <String>[].obs;
  RxList<String>  instrumentFilters  = <String>[].obs;
  RxList<String>  immunologyInstrumentFilters  = <String>[].obs;
  RxList<String>  selectedBrandFilters         = <String>[].obs;
  RxList<String>  selectedParameterFilters     = <String>[].obs;
  RxList<String>  selectedProductFilters       = <String>[].obs;
  RxList<String>  selectedInstrumentFilters    = <String>[].obs;
  RxList<String>  selectedImmunologyInstrumentFilters   = <String>[].obs;
  List<int>       selectedProductFilterIds = [];
  Map<String,String> productsFilterMap = {};

  RefreshController refreshController = RefreshController();

  //..........................................................................................................................
  List<String> tempProductFilters   = [];
  List<String> tempBrandFilters     = [];
  List<String> tempParameterFilters = [];
  bool makeApiCall = false;

  //
  getFilteredProducts({String query=""}) async {

    if (filterCheck() &&
        query.isNotEmpty &&
        reagentsFilteredData.isNotEmpty &&
        mainFilterType.value == 2) {
      searchReagents(query);
      return;
    }
    if (mainFilterType.value == 1 || pageIndex == 0) {
        isFiltering.value = true;
      }
      if (mainFilterType.value == 2 && !filterCheck() && query.isNotEmpty) {
        isFiltering.value = true;
      }
      if (filterCheck()) {
        isFiltering.value = true;
      }
      if (mainFilterType.value == 2 && query.isEmpty && !filterCheck()) {
        pageIndex++;
      }
      getProductFilterIds();
      await Repository().getFilteredCategoryProducts(
          mainFilter: mainFilterType.value,
          category_id: categoryId,
          chosenBrands: selectedBrandFilters,
          chosenProducts: selectedProductFilterIds,
          chosenParameters: selectedParameterFilters,
          pageIndex: pageIndex,
          search: query,
          filtersCallback: mainFilterType.value == 2
              ? getFilterDataFromApi
              : null
      ).then((value) {
        if (mainFilterType.value == 1) {
          instruments.addAll(value);
        }
        else {
          if(query.isNotEmpty){
            reagentsSearchFilteredData.addAll(value);
          }else if(filterCheck()){
            combinationFilterAfterApiCall(value);
          }
          else{
            reagents.addAll(value);
          }
          refreshController.refreshCompleted();
        }
        isFiltering.value = false;
      }).whenComplete(() {
        refreshController.refreshCompleted();
        refreshController.loadComplete();
      });
  }

  //
  combinationFilterAfterApiCall(List<CategoryProductData> products) {
    if (selectedProductFilters.isNotEmpty) {
      if(selectedBrandFilters.isEmpty && selectedParameterFilters.isEmpty){
        reagentsFilteredData.addAll(products);
        return;
      }
      if (selectedBrandFilters.isNotEmpty) {
        for (var element in products) {
          if (element.brand != null &&
              selectedBrandFilters.contains(element.brand)) {
            reagentsFilteredData.add(element);
          }
        }
      }
      if (selectedParameterFilters.isNotEmpty) {
        for (var element in reagentsFilteredData) {
          if (element.tags != null && element.tags!.isNotEmpty &&
              selectedParameterFilters.contains(element.tags)) {
            reagentsFilteredData.add(element);
          }
        }
      }
    }
    else if (selectedBrandFilters.isNotEmpty) {
      if (selectedParameterFilters.isNotEmpty) {
        for (var element in reagentsFilteredData) {
          if (element.tags != null && element.tags!.isNotEmpty &&
              selectedParameterFilters.contains(element.tags)) {
            reagentsFilteredData.add(element);
          }
        }
      }
      else{
        reagentsFilteredData.addAll(products);
      }
    }
    else if(selectedParameterFilters.isNotEmpty){
      reagentsFilteredData.addAll(products);
    }
    reagentsFilteredData.value.sort(
        (a,b){
          return a.tags!.toLowerCase().compareTo(b.tags!.toLowerCase());
        }
    );
  }


  //
  getProductFilterIds(){
    selectedProductFilterIds.clear();
    for (var element in selectedProductFilters) {
      if(productsFilterMap.containsKey(element)) {
        selectedProductFilterIds.add(int.parse(productsFilterMap[element]!));
      }
    }
  }

  //
  bool filterCheck(){
    if(selectedBrandFilters.isNotEmpty
        || selectedProductFilters.isNotEmpty
        || selectedParameterFilters.isNotEmpty){
      return true;
    }
    else {
      return false;
    }
  }

  //
  getFilterDataFromApi(Map<String,dynamic> filterData){
    if(brandFilters.isEmpty && parameterFilters.isEmpty && productFilters.isEmpty) {
      brandFilters.value = filterData['brands']!;
      parameterFilters.value = filterData['tags']!;
      try {
        productFilters.value =
            (filterData['products'] as Map<String, String>).keys.toSet().toList();
      }
      catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      productsFilterMap = filterData['products'];
    }
  }

  //
  processFilter({int ordering = 0}){
    filteredData.clear();
    for (var element in allProducts) {
      if(element.ordering==ordering){
        filteredData.add(element);
      }
    }
  }

  //
  immunologyFilter({bool value = false,int subfilter = 0}){
    isFiltering.value = true;
    filteredData.value = [];
    if(value){
      immunologySubFilterList.add(subfilter);
    }else{
      immunologySubFilterList.remove(subfilter);
    }
    for (var element in instruments) {
      if(immunologySubFilterList.contains(element.ordering)){
        filteredData.add(element);
      }
    }
    isFiltering.value = false;
  }

  //
  immunologyInstrumentsFilter(){
    filteredData.value = [];
    if(selectedImmunologyInstrumentFilters.isEmpty){
      immunologyFilter();
      return;
    }
    for (var element in instruments) {
       if(immunologySubFilterList.contains(element.ordering)
          && selectedImmunologyInstrumentFilters.contains(element.instrumentType)){
         filteredData.add(element);
       }
    }
  }

  //
  getImmunologyInstrumentsFilter(){
    filteredData.value = [];
    for (var element in instruments) {
      if(element.instrumentType!.isNotEmpty && !immunologyInstrumentFilters.contains(element.instrumentType)){
        immunologyInstrumentFilters.add(element.instrumentType!);
      }
    }
    selectedImmunologyInstrumentFilters.addAll(immunologyInstrumentFilters.toSet());
  }

  //
  filterInstruments(){
    if(selectedInstrumentFilters.isEmpty && title=="Immunology"){
      immunologyFilter();
      return;
    }
    if(selectedInstrumentFilters.isEmpty){
      processFilter(ordering: 1);
      return;
    }
    filteredData.value = instruments.where((v)=> selectedInstrumentFilters.contains(v.instrumentType)).toList();
  }

  //
  filterReagents(){
    mainFilterType.value=2;
    showingFilteredData.value=true;
    filteredData.value = [];

    if(selectedProductFilters.isNotEmpty){
      List<CategoryProductData> filteredProducts = [];
      for (var selectedFilter in selectedProductFilters) {
        reagents.where((v) => v.ordering == 2).toList().forEach((allproduct) {
          allproduct.linkedProducts?.forEach((element) {
            if(element.title == selectedFilter){
              filteredProducts.add(allproduct);
            }
          });
        });
        if(selectedBrandFilters.isNotEmpty){
          List<CategoryProductData> brandFilteredData = [];
          for (var brand in selectedBrandFilters) {
            if(selectedParameterFilters.isNotEmpty) {
              filteredProducts.where((v) => v.ordering == 2).toList().forEach((element) {
                if (element.brand == brand &&
                    (selectedParameterFilters.contains(element.tags))) {
                  brandFilteredData.add(element);
                }
              });
            }
            else{
              filteredProducts.where((v) => v.ordering == 2).toList().forEach((element) {
                if (element.brand == brand) {
                  brandFilteredData.add(element);
                }
              });
            }
          }
          filteredData.value = brandFilteredData;
        }
        else if(selectedParameterFilters.isNotEmpty){
          filteredProducts.where((v) => v.ordering == 2).toList().forEach((element) {
            if (selectedParameterFilters.contains(element.tags)) {
              filteredData.add(element);
            }
          });
        } else{
          filteredData.value = filteredProducts;
        }
      }
    }
    //no product filters selected
    else if(selectedBrandFilters.isNotEmpty){
      for (var brand in selectedBrandFilters) {
        if(selectedParameterFilters.isNotEmpty) {
          reagents.where((v) => v.ordering == 2).toList().forEach((element) {
            if (element.brand == brand &&
                (selectedParameterFilters.contains(element.tags))) {
              filteredData.add(element);
            }
          });
        }
        else{
          reagents.where((v) => v.ordering == 2).toList().forEach((element) {
            if (element.brand == brand) {
              filteredData.add(element);
            }
          });
        }
      }
    }
    //only parameter filter
    else if(selectedParameterFilters.isNotEmpty){
      reagents.where((v) => v.ordering == 2).toList().forEach((element) {
        if (selectedParameterFilters.contains(element.tags)) {
          filteredData.add(element);
        }
      });
    }
  }

  //
  getFilterItems(){
    if(title=="Immunology"){
      getImmunologyInstrumentsFilter();
    }
    if(mainFilterType.value==1){
      for (var value in instruments) {
        if(value.ordering==1){
          if(value.instrumentType!.isNotEmpty && !instrumentFilters.contains(value.instrumentType)){
            instrumentFilters.add(value.instrumentType!);
          }
        }
      }
    }
    else{
      for(var value in reagents){
        if(value.ordering==2){
          if(value.brand!.isNotEmpty && !brandFilters.contains(value.brand)) {
            brandFilters.add(value.brand!);
          }
          if(value.tags!.isNotEmpty && !parameterFilters.contains(value.tags)){
            parameterFilters.add(value.tags!);
          }
          if(value.linkedProducts!.isNotEmpty){
            for (var element in value.linkedProducts!) {
              if(!productFilters.contains(element.title)) {
                productFilters.add(element.title);
              }
            }
          }
        }
      }
    }
  }

  //
  searchReagents(String search){

    reagentsSearchFilteredData.value = [];
    String query = search.toLowerCase();

    for (var element in reagentsFilteredData) {
      if(element.title!=null && element.title!.toLowerCase().contains(query)){
        if(!reagentsSearchFilteredData.contains(element)) {
          reagentsSearchFilteredData.add(element);
        }
      }
      if(element.shortDescription!=null && element.shortDescription!.toLowerCase().contains(query)){
        if(!reagentsSearchFilteredData.contains(element)) {
          reagentsSearchFilteredData.add(element);
        }
      }
      if(element.sku!=null && element.sku!.toLowerCase().contains(query)){
        if(!reagentsSearchFilteredData.contains(element)) {
          reagentsSearchFilteredData.add(element);
        }
      }
      if(element.tags!=null && element.tags!.toLowerCase().contains(query)){
        if(!reagentsSearchFilteredData.contains(element)) {
          reagentsSearchFilteredData.add(element);
        }
      }
      if(element.description!=null && element.description!.toLowerCase().contains(query)){
        if(!reagentsSearchFilteredData.contains(element)) {
          reagentsSearchFilteredData.add(element);
        }
      }
    }
  }

  //
  searchProducts(String search){
    searchFilteredData.value = [];
    String query = search.toLowerCase();
    List<CategoryProductData> products = [];
    if(filteredData.isNotEmpty){
      products = filteredData;
    }
    else if(mainFilterType.value==1){
      products = instruments;
    }
    else if(mainFilterType.value==2){
      products = reagents;
    }
    for (var element in products) {
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
      if(element.tags!=null && element.tags!.toLowerCase().contains(query)){
        if(!searchFilteredData.contains(element)) {
          searchFilteredData.add(element);
        }
      }
      if(element.description!=null && element.description!.toLowerCase().contains(query)){
        if(!searchFilteredData.contains(element)) {
          searchFilteredData.add(element);
        }
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    if(subtitle=="Reagents"){
      mainFilterType.value = 2;
    }
    else if(subtitle == "Instruments"){
      mainFilterType.value = 1;
    }
    if(categoryId==7){
      mainFilterType.value = 2;
    }
    getFilteredProducts();
    instruments.stream.listen((event) {
      getFilterItems();
      showingFilteredData.value = true;
    });
    reagents.stream.listen((event) {
      //getFilterItems();
      showingFilteredData.value = true;
    });
  }

}