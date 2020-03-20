class Options{
  final String title;
  final List<String>  name;
  Options(this.title,this.name);
}


// class OptionModel {
//   String options;
//   // String alias;
//   List<String> lgas;

//   optionsModel({this.options, this.alias, this.lgas});

//   optionsModel.fromJson(Map<String, dynamic> json) {
//     options = json['options'];
//     alias = json['alias'];
//     lgas = json['lgas'].cast<String>();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['options'] = this.options;
//     data['alias'] = this.alias;
//     data['lgas'] = this.lgas;
//     return data;
//   }
// }