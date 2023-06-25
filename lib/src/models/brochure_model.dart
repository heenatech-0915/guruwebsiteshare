class BrochureModel {


  String ?title;
  String ?specification;

  BrochureModel({
    this.title,
    this.specification
});

  BrochureModel.fromJson(Map<String,dynamic> json){
    title = json['name'] ?? "";
    if(json['specification']!=null && json['specification'].runtimeType!=bool){
      specification = json['specification'];
    }
  }
}