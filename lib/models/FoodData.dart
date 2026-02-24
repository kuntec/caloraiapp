/// message : "Food added successfully"
/// food : {"name":"Boiled Egg","brand":"Home","description":"Large boiled egg","servingSize":1,"servingUnit":"piece","servingsPerContainer":1,"nutrients":{"calories":78,"protein_g":6,"carbs_g":0.6,"fats_g":5,"saturated_fat_g":1.6,"polyunsaturated_fat_g":0.7,"monounsaturated_fat_g":2,"trans_fat_g":0,"cholesterol_mg":186,"fiber_g":0,"sugar_g":0.6,"sodium_mg":62,"potassium_mg":63,"vitaminA_mcg":75,"vitaminC_mg":0,"calcium_mg":28,"iron_mg":0.9},"source":"user","createdBy":"69941c043a4dda52ad088ed9","verified":false,"imageUrl":"","_id":"6999995d77e80a6acff3b327","createdAt":"2026-02-21T11:39:09.190Z","updatedAt":"2026-02-21T11:39:09.190Z","__v":0}

class FoodData {
  FoodData({
    dynamic message,
    Food? food,
  }) {
    _message = message;
    _food = food;
  }

  FoodData.fromJson(dynamic json) {
    _message = json['message'];
    _food = json['food'] != null ? Food.fromJson(json['food']) : null;
  }
  dynamic _message;
  Food? _food;
  FoodData copyWith({
    dynamic message,
    Food? food,
  }) =>
      FoodData(
        message: message ?? _message,
        food: food ?? _food,
      );
  dynamic get message => _message;
  Food? get food => _food;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    if (_food != null) {
      map['food'] = _food?.toJson();
    }
    return map;
  }

  set food(dynamic value) {
    _food = value;
  }

  set message(dynamic value) {
    _message = value;
  }
}

/// name : "Boiled Egg"
/// brand : "Home"
/// description : "Large boiled egg"
/// servingSize : 1
/// servingUnit : "piece"
/// servingsPerContainer : 1
/// nutrients : {"calories":78,"protein_g":6,"carbs_g":0.6,"fats_g":5,"saturated_fat_g":1.6,"polyunsaturated_fat_g":0.7,"monounsaturated_fat_g":2,"trans_fat_g":0,"cholesterol_mg":186,"fiber_g":0,"sugar_g":0.6,"sodium_mg":62,"potassium_mg":63,"vitaminA_mcg":75,"vitaminC_mg":0,"calcium_mg":28,"iron_mg":0.9}
/// source : "user"
/// createdBy : "69941c043a4dda52ad088ed9"
/// verified : false
/// imageUrl : ""
/// _id : "6999995d77e80a6acff3b327"
/// createdAt : "2026-02-21T11:39:09.190Z"
/// updatedAt : "2026-02-21T11:39:09.190Z"
/// __v : 0

class Food {
  Food({
    dynamic name,
    dynamic brand,
    dynamic description,
    dynamic servingSize,
    dynamic servingUnit,
    dynamic servingsPerContainer,
    Nutrients? nutrients,
    dynamic source,
    dynamic createdBy,
    dynamic verified,
    dynamic imageUrl,
    dynamic id,
    dynamic createdAt,
    dynamic updatedAt,
    dynamic v,
  }) {
    _name = name;
    _brand = brand;
    _description = description;
    _servingSize = servingSize;
    _servingUnit = servingUnit;
    _servingsPerContainer = servingsPerContainer;
    _nutrients = nutrients;
    _source = source;
    _createdBy = createdBy;
    _verified = verified;
    _imageUrl = imageUrl;
    _id = id;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  Food.fromJson(dynamic json) {
    _name = json['name'];
    _brand = json['brand'];
    _description = json['description'];
    _servingSize = json['servingSize'];
    _servingUnit = json['servingUnit'];
    _servingsPerContainer = json['servingsPerContainer'];
    _nutrients = json['nutrients'] != null
        ? Nutrients.fromJson(json['nutrients'])
        : null;
    _source = json['source'];
    _createdBy = json['createdBy'];
    _verified = json['verified'];
    _imageUrl = json['imageUrl'];
    _id = json['_id'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  dynamic _name;
  dynamic _brand;
  dynamic _description;
  dynamic _servingSize;
  dynamic _servingUnit;
  dynamic _servingsPerContainer;
  Nutrients? _nutrients;
  dynamic _source;
  dynamic _createdBy;
  dynamic _verified;
  dynamic _imageUrl;
  dynamic _id;
  dynamic _createdAt;
  dynamic _updatedAt;
  dynamic _v;
  Food copyWith({
    dynamic name,
    dynamic brand,
    dynamic description,
    dynamic servingSize,
    dynamic servingUnit,
    dynamic servingsPerContainer,
    Nutrients? nutrients,
    dynamic source,
    dynamic createdBy,
    dynamic verified,
    dynamic imageUrl,
    dynamic id,
    dynamic createdAt,
    dynamic updatedAt,
    dynamic v,
  }) =>
      Food(
        name: name ?? _name,
        brand: brand ?? _brand,
        description: description ?? _description,
        servingSize: servingSize ?? _servingSize,
        servingUnit: servingUnit ?? _servingUnit,
        servingsPerContainer: servingsPerContainer ?? _servingsPerContainer,
        nutrients: nutrients ?? _nutrients,
        source: source ?? _source,
        createdBy: createdBy ?? _createdBy,
        verified: verified ?? _verified,
        imageUrl: imageUrl ?? _imageUrl,
        id: id ?? _id,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );
  dynamic get name => _name;
  dynamic get brand => _brand;
  dynamic get description => _description;
  dynamic get servingSize => _servingSize;
  dynamic get servingUnit => _servingUnit;
  dynamic get servingsPerContainer => _servingsPerContainer;
  Nutrients? get nutrients => _nutrients;
  dynamic get source => _source;
  dynamic get createdBy => _createdBy;
  dynamic get verified => _verified;
  dynamic get imageUrl => _imageUrl;
  dynamic get id => _id;
  dynamic get createdAt => _createdAt;
  dynamic get updatedAt => _updatedAt;
  dynamic get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['brand'] = _brand;
    map['description'] = _description;
    map['servingSize'] = _servingSize;
    map['servingUnit'] = _servingUnit;
    map['servingsPerContainer'] = _servingsPerContainer;
    if (_nutrients != null) {
      map['nutrients'] = _nutrients?.toJson();
    }
    map['source'] = _source;
    map['createdBy'] = _createdBy;
    map['verified'] = _verified;
    map['imageUrl'] = _imageUrl;
    map['_id'] = _id;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }

  set v(dynamic value) {
    _v = value;
  }

  set updatedAt(dynamic value) {
    _updatedAt = value;
  }

  set createdAt(dynamic value) {
    _createdAt = value;
  }

  set id(dynamic value) {
    _id = value;
  }

  set imageUrl(dynamic value) {
    _imageUrl = value;
  }

  set verified(dynamic value) {
    _verified = value;
  }

  set createdBy(dynamic value) {
    _createdBy = value;
  }

  set source(dynamic value) {
    _source = value;
  }

  set nutrients(dynamic value) {
    _nutrients = value;
  }

  set servingsPerContainer(dynamic value) {
    _servingsPerContainer = value;
  }

  set servingUnit(dynamic value) {
    _servingUnit = value;
  }

  set servingSize(dynamic value) {
    _servingSize = value;
  }

  set description(dynamic value) {
    _description = value;
  }

  set brand(dynamic value) {
    _brand = value;
  }

  set name(dynamic value) {
    _name = value;
  }
}

/// calories : 78
/// protein_g : 6
/// carbs_g : 0.6
/// fats_g : 5
/// saturated_fat_g : 1.6
/// polyunsaturated_fat_g : 0.7
/// monounsaturated_fat_g : 2
/// trans_fat_g : 0
/// cholesterol_mg : 186
/// fiber_g : 0
/// sugar_g : 0.6
/// sodium_mg : 62
/// potassium_mg : 63
/// vitaminA_mcg : 75
/// vitaminC_mg : 0
/// calcium_mg : 28
/// iron_mg : 0.9

class Nutrients {
  Nutrients({
    dynamic calories,
    dynamic proteinG,
    dynamic carbsG,
    dynamic fatsG,
    dynamic saturatedFatG,
    dynamic polyunsaturatedFatG,
    dynamic monounsaturatedFatG,
    dynamic transFatG,
    dynamic cholesterolMg,
    dynamic fiberG,
    dynamic sugarG,
    dynamic sodiumMg,
    dynamic potassiumMg,
    dynamic vitaminAMcg,
    dynamic vitaminCMg,
    dynamic calciumMg,
    dynamic ironMg,
  }) {
    _calories = calories;
    _proteinG = proteinG;
    _carbsG = carbsG;
    _fatsG = fatsG;
    _saturatedFatG = saturatedFatG;
    _polyunsaturatedFatG = polyunsaturatedFatG;
    _monounsaturatedFatG = monounsaturatedFatG;
    _transFatG = transFatG;
    _cholesterolMg = cholesterolMg;
    _fiberG = fiberG;
    _sugarG = sugarG;
    _sodiumMg = sodiumMg;
    _potassiumMg = potassiumMg;
    _vitaminAMcg = vitaminAMcg;
    _vitaminCMg = vitaminCMg;
    _calciumMg = calciumMg;
    _ironMg = ironMg;
  }

  Nutrients.fromJson(dynamic json) {
    _calories = json['calories'];
    _proteinG = json['protein_g'];
    _carbsG = json['carbs_g'];
    _fatsG = json['fats_g'];
    _saturatedFatG = json['saturated_fat_g'];
    _polyunsaturatedFatG = json['polyunsaturated_fat_g'];
    _monounsaturatedFatG = json['monounsaturated_fat_g'];
    _transFatG = json['trans_fat_g'];
    _cholesterolMg = json['cholesterol_mg'];
    _fiberG = json['fiber_g'];
    _sugarG = json['sugar_g'];
    _sodiumMg = json['sodium_mg'];
    _potassiumMg = json['potassium_mg'];
    _vitaminAMcg = json['vitaminA_mcg'];
    _vitaminCMg = json['vitaminC_mg'];
    _calciumMg = json['calcium_mg'];
    _ironMg = json['iron_mg'];
  }
  dynamic _calories;
  dynamic _proteinG;
  dynamic _carbsG;
  dynamic _fatsG;
  dynamic _saturatedFatG;
  dynamic _polyunsaturatedFatG;
  dynamic _monounsaturatedFatG;
  dynamic _transFatG;
  dynamic _cholesterolMg;
  dynamic _fiberG;
  dynamic _sugarG;
  dynamic _sodiumMg;
  dynamic _potassiumMg;
  dynamic _vitaminAMcg;
  dynamic _vitaminCMg;
  dynamic _calciumMg;
  dynamic _ironMg;
  Nutrients copyWith({
    dynamic calories,
    dynamic proteinG,
    dynamic carbsG,
    dynamic fatsG,
    dynamic saturatedFatG,
    dynamic polyunsaturatedFatG,
    dynamic monounsaturatedFatG,
    dynamic transFatG,
    dynamic cholesterolMg,
    dynamic fiberG,
    dynamic sugarG,
    dynamic sodiumMg,
    dynamic potassiumMg,
    dynamic vitaminAMcg,
    dynamic vitaminCMg,
    dynamic calciumMg,
    dynamic ironMg,
  }) =>
      Nutrients(
        calories: calories ?? _calories,
        proteinG: proteinG ?? _proteinG,
        carbsG: carbsG ?? _carbsG,
        fatsG: fatsG ?? _fatsG,
        saturatedFatG: saturatedFatG ?? _saturatedFatG,
        polyunsaturatedFatG: polyunsaturatedFatG ?? _polyunsaturatedFatG,
        monounsaturatedFatG: monounsaturatedFatG ?? _monounsaturatedFatG,
        transFatG: transFatG ?? _transFatG,
        cholesterolMg: cholesterolMg ?? _cholesterolMg,
        fiberG: fiberG ?? _fiberG,
        sugarG: sugarG ?? _sugarG,
        sodiumMg: sodiumMg ?? _sodiumMg,
        potassiumMg: potassiumMg ?? _potassiumMg,
        vitaminAMcg: vitaminAMcg ?? _vitaminAMcg,
        vitaminCMg: vitaminCMg ?? _vitaminCMg,
        calciumMg: calciumMg ?? _calciumMg,
        ironMg: ironMg ?? _ironMg,
      );
  dynamic get calories => _calories;
  dynamic get proteinG => _proteinG;
  dynamic get carbsG => _carbsG;
  dynamic get fatsG => _fatsG;
  dynamic get saturatedFatG => _saturatedFatG;
  dynamic get polyunsaturatedFatG => _polyunsaturatedFatG;
  dynamic get monounsaturatedFatG => _monounsaturatedFatG;
  dynamic get transFatG => _transFatG;
  dynamic get cholesterolMg => _cholesterolMg;
  dynamic get fiberG => _fiberG;
  dynamic get sugarG => _sugarG;
  dynamic get sodiumMg => _sodiumMg;
  dynamic get potassiumMg => _potassiumMg;
  dynamic get vitaminAMcg => _vitaminAMcg;
  dynamic get vitaminCMg => _vitaminCMg;
  dynamic get calciumMg => _calciumMg;
  dynamic get ironMg => _ironMg;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['calories'] = _calories;
    map['protein_g'] = _proteinG;
    map['carbs_g'] = _carbsG;
    map['fats_g'] = _fatsG;
    map['saturated_fat_g'] = _saturatedFatG;
    map['polyunsaturated_fat_g'] = _polyunsaturatedFatG;
    map['monounsaturated_fat_g'] = _monounsaturatedFatG;
    map['trans_fat_g'] = _transFatG;
    map['cholesterol_mg'] = _cholesterolMg;
    map['fiber_g'] = _fiberG;
    map['sugar_g'] = _sugarG;
    map['sodium_mg'] = _sodiumMg;
    map['potassium_mg'] = _potassiumMg;
    map['vitaminA_mcg'] = _vitaminAMcg;
    map['vitaminC_mg'] = _vitaminCMg;
    map['calcium_mg'] = _calciumMg;
    map['iron_mg'] = _ironMg;
    return map;
  }

  set ironMg(dynamic value) {
    _ironMg = value;
  }

  set calciumMg(dynamic value) {
    _calciumMg = value;
  }

  set vitaminCMg(dynamic value) {
    _vitaminCMg = value;
  }

  set vitaminAMcg(dynamic value) {
    _vitaminAMcg = value;
  }

  set potassiumMg(dynamic value) {
    _potassiumMg = value;
  }

  set sodiumMg(dynamic value) {
    _sodiumMg = value;
  }

  set sugarG(dynamic value) {
    _sugarG = value;
  }

  set fiberG(dynamic value) {
    _fiberG = value;
  }

  set cholesterolMg(dynamic value) {
    _cholesterolMg = value;
  }

  set transFatG(dynamic value) {
    _transFatG = value;
  }

  set monounsaturatedFatG(dynamic value) {
    _monounsaturatedFatG = value;
  }

  set polyunsaturatedFatG(dynamic value) {
    _polyunsaturatedFatG = value;
  }

  set saturatedFatG(dynamic value) {
    _saturatedFatG = value;
  }

  set fatsG(dynamic value) {
    _fatsG = value;
  }

  set carbsG(dynamic value) {
    _carbsG = value;
  }

  set proteinG(dynamic value) {
    _proteinG = value;
  }

  set calories(dynamic value) {
    _calories = value;
  }
}
