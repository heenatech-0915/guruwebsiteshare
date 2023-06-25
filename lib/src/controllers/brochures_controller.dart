import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/brochure_model.dart';
import '../servers/repository.dart';

class BrochuresController extends GetxController{

  RxBool isLoading = false.obs;
  RefreshController rc = RefreshController();

  RxList<BrochureModel> pdf = <BrochureModel>[].obs;
  int page = 0;

   //
   getBrochuresData() async {
    page++;
    isLoading.value = true;
    return await Repository().getBrochures(page).then((value){
      isLoading.value = false;
      if(page==1){
        pdf.value = value;
      }
      else{
        pdf.addAll(value);
      }
      return pdf;
    }).whenComplete((){
      isLoading.value = false;
      rc.loadComplete();
      rc.refreshCompleted();
    });
  }

  @override
  void onInit() {
    super.onInit();
    getBrochuresData();
  }

}
