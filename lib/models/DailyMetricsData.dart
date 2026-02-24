/// metrics : {"userId":"69941c043a4dda52ad088ed9","date":"2026-02-18T00:00:00.000Z","waterIntake":{"totalMl":0,"goalMl":2000,"isGoalAchieved":false},"steps":{"count":0,"goal":10000,"isGoalAchieved":false},"caloriesBurned":0,"syncSource":"manual","_id":"69954f2f18366ae8c437aa98","nutrientsConsumed":{"calories":0,"protein_g":0,"carbs_g":0,"fats_g":0,"fiber_g":0,"sugar_g":0,"sodium_mg":0,"potassium_mg":0,"cholesterol_mg":0,"vitaminA_mcg":0,"vitaminC_mg":0,"calcium_mg":0,"iron_mg":0},"createdAt":"2026-02-18T05:33:35.658Z","updatedAt":"2026-02-18T05:33:35.658Z","__v":0}

class DailyMetricsData {
  DailyMetricsData({
    Metrics? metrics,
  }) {
    _metrics = metrics;
  }

  DailyMetricsData.fromJson(dynamic json) {
    _metrics =
        json['metrics'] != null ? Metrics.fromJson(json['metrics']) : null;
  }
  Metrics? _metrics;
  DailyMetricsData copyWith({
    Metrics? metrics,
  }) =>
      DailyMetricsData(
        metrics: metrics ?? _metrics,
      );
  Metrics? get metrics => _metrics;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_metrics != null) {
      map['metrics'] = _metrics?.toJson();
    }
    return map;
  }
}

/// userId : "69941c043a4dda52ad088ed9"
/// date : "2026-02-18T00:00:00.000Z"
/// waterIntake : {"totalMl":0,"goalMl":2000,"isGoalAchieved":false}
/// steps : {"count":0,"goal":10000,"isGoalAchieved":false}
/// caloriesBurned : 0
/// syncSource : "manual"
/// _id : "69954f2f18366ae8c437aa98"
/// nutrientsConsumed : {"calories":0,"protein_g":0,"carbs_g":0,"fats_g":0,"fiber_g":0,"sugar_g":0,"sodium_mg":0,"potassium_mg":0,"cholesterol_mg":0,"vitaminA_mcg":0,"vitaminC_mg":0,"calcium_mg":0,"iron_mg":0}
/// createdAt : "2026-02-18T05:33:35.658Z"
/// updatedAt : "2026-02-18T05:33:35.658Z"
/// __v : 0

class Metrics {
  Metrics({
    String? userId,
    String? date,
    WaterIntake? waterIntake,
    Steps? steps,
    num? caloriesBurned,
    String? syncSource,
    String? id,
    NutrientsConsumed? nutrientsConsumed,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _userId = userId;
    _date = date;
    _waterIntake = waterIntake;
    _steps = steps;
    _caloriesBurned = caloriesBurned;
    _syncSource = syncSource;
    _id = id;
    _nutrientsConsumed = nutrientsConsumed;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  Metrics.fromJson(dynamic json) {
    _userId = json['userId'];
    _date = json['date'];
    _waterIntake = json['waterIntake'] != null
        ? WaterIntake.fromJson(json['waterIntake'])
        : null;
    _steps = json['steps'] != null ? Steps.fromJson(json['steps']) : null;
    _caloriesBurned = json['caloriesBurned'];
    _syncSource = json['syncSource'];
    _id = json['_id'];
    _nutrientsConsumed = json['nutrientsConsumed'] != null
        ? NutrientsConsumed.fromJson(json['nutrientsConsumed'])
        : null;
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _userId;
  String? _date;
  WaterIntake? _waterIntake;
  Steps? _steps;
  num? _caloriesBurned;
  String? _syncSource;
  String? _id;
  NutrientsConsumed? _nutrientsConsumed;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  Metrics copyWith({
    String? userId,
    String? date,
    WaterIntake? waterIntake,
    Steps? steps,
    num? caloriesBurned,
    String? syncSource,
    String? id,
    NutrientsConsumed? nutrientsConsumed,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) =>
      Metrics(
        userId: userId ?? _userId,
        date: date ?? _date,
        waterIntake: waterIntake ?? _waterIntake,
        steps: steps ?? _steps,
        caloriesBurned: caloriesBurned ?? _caloriesBurned,
        syncSource: syncSource ?? _syncSource,
        id: id ?? _id,
        nutrientsConsumed: nutrientsConsumed ?? _nutrientsConsumed,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );
  String? get userId => _userId;
  String? get date => _date;
  WaterIntake? get waterIntake => _waterIntake;
  Steps? get steps => _steps;
  num? get caloriesBurned => _caloriesBurned;
  String? get syncSource => _syncSource;
  String? get id => _id;
  NutrientsConsumed? get nutrientsConsumed => _nutrientsConsumed;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userId'] = _userId;
    map['date'] = _date;
    if (_waterIntake != null) {
      map['waterIntake'] = _waterIntake?.toJson();
    }
    if (_steps != null) {
      map['steps'] = _steps?.toJson();
    }
    map['caloriesBurned'] = _caloriesBurned;
    map['syncSource'] = _syncSource;
    map['_id'] = _id;
    if (_nutrientsConsumed != null) {
      map['nutrientsConsumed'] = _nutrientsConsumed?.toJson();
    }
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}

/// calories : 0
/// protein_g : 0
/// carbs_g : 0
/// fats_g : 0
/// fiber_g : 0
/// sugar_g : 0
/// sodium_mg : 0
/// potassium_mg : 0
/// cholesterol_mg : 0
/// vitaminA_mcg : 0
/// vitaminC_mg : 0
/// calcium_mg : 0
/// iron_mg : 0

class NutrientsConsumed {
  NutrientsConsumed({
    num? calories,
    num? proteinG,
    num? carbsG,
    num? fatsG,
    num? fiberG,
    num? sugarG,
    num? sodiumMg,
    num? potassiumMg,
    num? cholesterolMg,
    num? vitaminAMcg,
    num? vitaminCMg,
    num? calciumMg,
    num? ironMg,
  }) {
    _calories = calories;
    _proteinG = proteinG;
    _carbsG = carbsG;
    _fatsG = fatsG;
    _fiberG = fiberG;
    _sugarG = sugarG;
    _sodiumMg = sodiumMg;
    _potassiumMg = potassiumMg;
    _cholesterolMg = cholesterolMg;
    _vitaminAMcg = vitaminAMcg;
    _vitaminCMg = vitaminCMg;
    _calciumMg = calciumMg;
    _ironMg = ironMg;
  }

  NutrientsConsumed.fromJson(dynamic json) {
    _calories = json['calories'];
    _proteinG = json['protein_g'];
    _carbsG = json['carbs_g'];
    _fatsG = json['fats_g'];
    _fiberG = json['fiber_g'];
    _sugarG = json['sugar_g'];
    _sodiumMg = json['sodium_mg'];
    _potassiumMg = json['potassium_mg'];
    _cholesterolMg = json['cholesterol_mg'];
    _vitaminAMcg = json['vitaminA_mcg'];
    _vitaminCMg = json['vitaminC_mg'];
    _calciumMg = json['calcium_mg'];
    _ironMg = json['iron_mg'];
  }
  num? _calories;
  num? _proteinG;
  num? _carbsG;
  num? _fatsG;
  num? _fiberG;
  num? _sugarG;
  num? _sodiumMg;
  num? _potassiumMg;
  num? _cholesterolMg;
  num? _vitaminAMcg;
  num? _vitaminCMg;
  num? _calciumMg;
  num? _ironMg;
  NutrientsConsumed copyWith({
    num? calories,
    num? proteinG,
    num? carbsG,
    num? fatsG,
    num? fiberG,
    num? sugarG,
    num? sodiumMg,
    num? potassiumMg,
    num? cholesterolMg,
    num? vitaminAMcg,
    num? vitaminCMg,
    num? calciumMg,
    num? ironMg,
  }) =>
      NutrientsConsumed(
        calories: calories ?? _calories,
        proteinG: proteinG ?? _proteinG,
        carbsG: carbsG ?? _carbsG,
        fatsG: fatsG ?? _fatsG,
        fiberG: fiberG ?? _fiberG,
        sugarG: sugarG ?? _sugarG,
        sodiumMg: sodiumMg ?? _sodiumMg,
        potassiumMg: potassiumMg ?? _potassiumMg,
        cholesterolMg: cholesterolMg ?? _cholesterolMg,
        vitaminAMcg: vitaminAMcg ?? _vitaminAMcg,
        vitaminCMg: vitaminCMg ?? _vitaminCMg,
        calciumMg: calciumMg ?? _calciumMg,
        ironMg: ironMg ?? _ironMg,
      );
  num? get calories => _calories;
  num? get proteinG => _proteinG;
  num? get carbsG => _carbsG;
  num? get fatsG => _fatsG;
  num? get fiberG => _fiberG;
  num? get sugarG => _sugarG;
  num? get sodiumMg => _sodiumMg;
  num? get potassiumMg => _potassiumMg;
  num? get cholesterolMg => _cholesterolMg;
  num? get vitaminAMcg => _vitaminAMcg;
  num? get vitaminCMg => _vitaminCMg;
  num? get calciumMg => _calciumMg;
  num? get ironMg => _ironMg;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['calories'] = _calories;
    map['protein_g'] = _proteinG;
    map['carbs_g'] = _carbsG;
    map['fats_g'] = _fatsG;
    map['fiber_g'] = _fiberG;
    map['sugar_g'] = _sugarG;
    map['sodium_mg'] = _sodiumMg;
    map['potassium_mg'] = _potassiumMg;
    map['cholesterol_mg'] = _cholesterolMg;
    map['vitaminA_mcg'] = _vitaminAMcg;
    map['vitaminC_mg'] = _vitaminCMg;
    map['calcium_mg'] = _calciumMg;
    map['iron_mg'] = _ironMg;
    return map;
  }
}

/// count : 0
/// goal : 10000
/// isGoalAchieved : false

class Steps {
  Steps({
    num? count,
    num? goal,
    bool? isGoalAchieved,
  }) {
    _count = count;
    _goal = goal;
    _isGoalAchieved = isGoalAchieved;
  }

  Steps.fromJson(dynamic json) {
    _count = json['count'];
    _goal = json['goal'];
    _isGoalAchieved = json['isGoalAchieved'];
  }
  num? _count;
  num? _goal;
  bool? _isGoalAchieved;
  Steps copyWith({
    num? count,
    num? goal,
    bool? isGoalAchieved,
  }) =>
      Steps(
        count: count ?? _count,
        goal: goal ?? _goal,
        isGoalAchieved: isGoalAchieved ?? _isGoalAchieved,
      );
  num? get count => _count;
  num? get goal => _goal;
  bool? get isGoalAchieved => _isGoalAchieved;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['count'] = _count;
    map['goal'] = _goal;
    map['isGoalAchieved'] = _isGoalAchieved;
    return map;
  }
}

/// totalMl : 0
/// goalMl : 2000
/// isGoalAchieved : false

class WaterIntake {
  WaterIntake({
    num? totalMl,
    num? goalMl,
    bool? isGoalAchieved,
  }) {
    _totalMl = totalMl;
    _goalMl = goalMl;
    _isGoalAchieved = isGoalAchieved;
  }

  WaterIntake.fromJson(dynamic json) {
    _totalMl = json['totalMl'];
    _goalMl = json['goalMl'];
    _isGoalAchieved = json['isGoalAchieved'];
  }
  num? _totalMl;
  num? _goalMl;
  bool? _isGoalAchieved;
  WaterIntake copyWith({
    num? totalMl,
    num? goalMl,
    bool? isGoalAchieved,
  }) =>
      WaterIntake(
        totalMl: totalMl ?? _totalMl,
        goalMl: goalMl ?? _goalMl,
        isGoalAchieved: isGoalAchieved ?? _isGoalAchieved,
      );
  num? get totalMl => _totalMl;
  num? get goalMl => _goalMl;
  bool? get isGoalAchieved => _isGoalAchieved;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['totalMl'] = _totalMl;
    map['goalMl'] = _goalMl;
    map['isGoalAchieved'] = _isGoalAchieved;
    return map;
  }
}
