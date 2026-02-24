import 'package:calorai/models/FoodData.dart';

/// foods : [{"nutrients":{"calories":200,"protein_g":1,"carbs_g":1,"fats_g":11,"saturated_fat_g":1,"polyunsaturated_fat_g":1,"monounsaturated_fat_g":1,"trans_fat_g":0,"cholesterol_mg":0,"fiber_g":0,"sugar_g":0,"sodium_mg":0,"potassium_mg":0,"vitaminA_mcg":0,"vitaminC_mg":null,"calcium_mg":null,"iron_mg":null},"_id":"699aba82fe7818a9e3f829da","name":"chicken","brand":"Home","description":"chicken breast","servingSize":1,"servingUnit":"serving","source":"user","verified":false,"imageUrl":""},{"nutrients":{"calories":200,"protein_g":1,"carbs_g":1,"fats_g":11,"saturated_fat_g":1,"polyunsaturated_fat_g":1,"monounsaturated_fat_g":1,"trans_fat_g":0,"cholesterol_mg":0,"fiber_g":0,"sugar_g":0,"sodium_mg":0,"potassium_mg":0,"vitaminA_mcg":0,"vitaminC_mg":null,"calcium_mg":null,"iron_mg":null},"_id":"699aba78fe7818a9e3f829d8","name":"chicken","brand":"Home","description":"chicken breast","servingSize":1,"servingUnit":"serving","source":"user","verified":false,"imageUrl":""},{"nutrients":{"calories":78,"protein_g":6,"carbs_g":0.6,"fats_g":5,"saturated_fat_g":1.6,"polyunsaturated_fat_g":0.7,"monounsaturated_fat_g":2,"trans_fat_g":0,"cholesterol_mg":186,"fiber_g":0,"sugar_g":0.6,"sodium_mg":62,"potassium_mg":63,"vitaminA_mcg":75,"vitaminC_mg":0,"calcium_mg":28,"iron_mg":0.9},"_id":"699ab9b6b17670a7f5e0d48c","name":"Boiled Egg","brand":"Home","description":"Large boiled egg","servingSize":1,"servingUnit":"piece","source":"user","verified":false,"imageUrl":""},{"nutrients":{"calories":78,"protein_g":6,"carbs_g":0.6,"fats_g":5,"saturated_fat_g":1.6,"polyunsaturated_fat_g":0.7,"monounsaturated_fat_g":2,"trans_fat_g":0,"cholesterol_mg":186,"fiber_g":0,"sugar_g":0.6,"sodium_mg":62,"potassium_mg":63,"vitaminA_mcg":75,"vitaminC_mg":0,"calcium_mg":28,"iron_mg":0.9},"_id":"699ab91eb17670a7f5e0d486","name":"Boiled Egg","brand":"Home","description":"Large boiled egg","servingSize":1,"servingUnit":"piece","source":"user","verified":false,"imageUrl":""},{"nutrients":{"calories":78,"protein_g":6,"carbs_g":0.6,"fats_g":5,"saturated_fat_g":1.6,"polyunsaturated_fat_g":0.7,"monounsaturated_fat_g":2,"trans_fat_g":0,"cholesterol_mg":186,"fiber_g":0,"sugar_g":0.6,"sodium_mg":62,"potassium_mg":63,"vitaminA_mcg":75,"vitaminC_mg":0,"calcium_mg":28,"iron_mg":0.9},"_id":"699ab1acb17670a7f5e0d47c","name":"Boiled Egg","brand":"Home","description":"Large boiled egg","servingSize":1,"servingUnit":"piece","source":"user","verified":false,"imageUrl":""},{"nutrients":{"calories":78,"protein_g":6,"carbs_g":0.6,"fats_g":5,"saturated_fat_g":1.6,"polyunsaturated_fat_g":0.7,"monounsaturated_fat_g":2,"trans_fat_g":0,"cholesterol_mg":186,"fiber_g":0,"sugar_g":0.6,"sodium_mg":62,"potassium_mg":63,"vitaminA_mcg":75,"vitaminC_mg":0,"calcium_mg":28,"iron_mg":0.9},"_id":"6999995d77e80a6acff3b327","name":"Boiled Egg","brand":"Home","description":"Large boiled egg","servingSize":1,"servingUnit":"piece","source":"user","verified":false,"imageUrl":""}]
/// total : 6

class SearchFoodData {
  SearchFoodData({
    List<Food>? foods,
    dynamic total,
  }) {
    _foods = foods;
    _total = total;
  }

  SearchFoodData.fromJson(dynamic json) {
    if (json['foods'] != null) {
      _foods = [];
      json['foods'].forEach((v) {
        _foods?.add(Food.fromJson(v));
      });
    }
    _total = json['total'];
  }
  List<Food>? _foods;
  dynamic _total;
  SearchFoodData copyWith({
    List<Food>? foods,
    dynamic total,
  }) =>
      SearchFoodData(
        foods: foods ?? _foods,
        total: total ?? _total,
      );
  List<Food>? get foods => _foods;
  dynamic get total => _total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_foods != null) {
      map['foods'] = _foods?.map((v) => v.toJson()).toList();
    }
    map['total'] = _total;
    return map;
  }
}

/// nutrients : {"calories":200,"protein_g":1,"carbs_g":1,"fats_g":11,"saturated_fat_g":1,"polyunsaturated_fat_g":1,"monounsaturated_fat_g":1,"trans_fat_g":0,"cholesterol_mg":0,"fiber_g":0,"sugar_g":0,"sodium_mg":0,"potassium_mg":0,"vitaminA_mcg":0,"vitaminC_mg":null,"calcium_mg":null,"iron_mg":null}
/// _id : "699aba82fe7818a9e3f829da"
/// name : "chicken"
/// brand : "Home"
/// description : "chicken breast"
/// servingSize : 1
/// servingUnit : "serving"
/// source : "user"
/// verified : false
/// imageUrl : ""

// class Foods {
//   Foods({
//     Nutrients? nutrients,
//     String? id,
//     String? name,
//     String? brand,
//     String? description,
//     dynamic servingSize,
//     String? servingUnit,
//     String? source,
//     bool? verified,
//     String? imageUrl,
//   }) {
//     _nutrients = nutrients;
//     _id = id;
//     _name = name;
//     _brand = brand;
//     _description = description;
//     _servingSize = servingSize;
//     _servingUnit = servingUnit;
//     _source = source;
//     _verified = verified;
//     _imageUrl = imageUrl;
//   }
//
//   Foods.fromJson(dynamic json) {
//     _nutrients = json['nutrients'] != null
//         ? Nutrients.fromJson(json['nutrients'])
//         : null;
//     _id = json['_id'];
//     _name = json['name'];
//     _brand = json['brand'];
//     _description = json['description'];
//     _servingSize = json['servingSize'];
//     _servingUnit = json['servingUnit'];
//     _source = json['source'];
//     _verified = json['verified'];
//     _imageUrl = json['imageUrl'];
//   }
//   Nutrients? _nutrients;
//   String? _id;
//   String? _name;
//   String? _brand;
//   String? _description;
//   dynamic _servingSize;
//   String? _servingUnit;
//   String? _source;
//   bool? _verified;
//   String? _imageUrl;
//   Foods copyWith({
//     Nutrients? nutrients,
//     String? id,
//     String? name,
//     String? brand,
//     String? description,
//     dynamic servingSize,
//     String? servingUnit,
//     String? source,
//     bool? verified,
//     String? imageUrl,
//   }) =>
//       Foods(
//         nutrients: nutrients ?? _nutrients,
//         id: id ?? _id,
//         name: name ?? _name,
//         brand: brand ?? _brand,
//         description: description ?? _description,
//         servingSize: servingSize ?? _servingSize,
//         servingUnit: servingUnit ?? _servingUnit,
//         source: source ?? _source,
//         verified: verified ?? _verified,
//         imageUrl: imageUrl ?? _imageUrl,
//       );
//   Nutrients? get nutrients => _nutrients;
//   String? get id => _id;
//   String? get name => _name;
//   String? get brand => _brand;
//   String? get description => _description;
//   dynamic get servingSize => _servingSize;
//   String? get servingUnit => _servingUnit;
//   String? get source => _source;
//   bool? get verified => _verified;
//   String? get imageUrl => _imageUrl;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     if (_nutrients != null) {
//       map['nutrients'] = _nutrients?.toJson();
//     }
//     map['_id'] = _id;
//     map['name'] = _name;
//     map['brand'] = _brand;
//     map['description'] = _description;
//     map['servingSize'] = _servingSize;
//     map['servingUnit'] = _servingUnit;
//     map['source'] = _source;
//     map['verified'] = _verified;
//     map['imageUrl'] = _imageUrl;
//     return map;
//   }
// }
