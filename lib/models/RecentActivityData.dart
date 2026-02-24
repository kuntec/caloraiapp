/// date : "2026-02-22T00:00:00.000Z"
/// activities : [{"type":"food","id":"699acce2fe7818a9e3f82a2b","date":"2026-02-22T00:00:00.000Z","time":"01:31 PM","title":"chicken","mealType":"lunch","servings":1,"subtitle":"lunch • 1 serving","calories":200,"macros":{"protein_g":1,"carbs_g":1,"fats_g":11},"createdAt":"2026-02-22T09:31:14.559Z"},{"type":"food","id":"699acc80fe7818a9e3f82a21","date":"2026-02-22T00:00:00.000Z","time":"01:29 PM","title":"chicken","mealType":"lunch","servings":1,"subtitle":"lunch • 1 serving","calories":200,"macros":{"protein_g":1,"carbs_g":1,"fats_g":11},"createdAt":"2026-02-22T09:29:36.763Z"},{"type":"exercise","id":"699acc7bfe7818a9e3f82a1b","date":"2026-02-22T00:00:00.000Z","time":"01:29 PM","title":"Manual Calorie","exerciseType":"run","intensity":"low","durationMin":30,"calories":655,"createdAt":"2026-02-22T09:29:31.845Z"},{"type":"food","id":"699acc60fe7818a9e3f82a07","date":"2026-02-22T00:00:00.000Z","time":"01:28 PM","title":"chicken","mealType":"lunch","servings":1,"subtitle":"lunch • 1 serving","calories":200,"macros":{"protein_g":1,"carbs_g":1,"fats_g":11},"createdAt":"2026-02-22T09:29:04.928Z"},{"type":"food","id":"699acc58fe7818a9e3f82a03","date":"2026-02-22T00:00:00.000Z","time":"01:28 PM","title":"Boiled Egg","mealType":"lunch","servings":1,"subtitle":"lunch • 1 serving","calories":78,"macros":{"protein_g":6,"carbs_g":0.6,"fats_g":5},"createdAt":"2026-02-22T09:28:56.574Z"}]
/// counts : {"foods":4,"exercises":1,"total":5}

class RecentActivityData {
  RecentActivityData({
    dynamic date,
    List<Activities>? activities,
    Counts? counts,
  }) {
    _date = date;
    _activities = activities;
    _counts = counts;
  }

  RecentActivityData.fromJson(dynamic json) {
    _date = json['date'];
    if (json['activities'] != null) {
      _activities = [];
      json['activities'].forEach((v) {
        _activities?.add(Activities.fromJson(v));
      });
    }
    _counts = json['counts'] != null ? Counts.fromJson(json['counts']) : null;
  }
  dynamic _date;
  List<Activities>? _activities;
  Counts? _counts;
  RecentActivityData copyWith({
    dynamic date,
    List<Activities>? activities,
    Counts? counts,
  }) =>
      RecentActivityData(
        date: date ?? _date,
        activities: activities ?? _activities,
        counts: counts ?? _counts,
      );
  dynamic get date => _date;
  List<Activities>? get activities => _activities;
  Counts? get counts => _counts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['date'] = _date;
    if (_activities != null) {
      map['activities'] = _activities?.map((v) => v.toJson()).toList();
    }
    if (_counts != null) {
      map['counts'] = _counts?.toJson();
    }
    return map;
  }
}

/// foods : 4
/// exercises : 1
/// total : 5

class Counts {
  Counts({
    dynamic foods,
    dynamic exercises,
    dynamic total,
  }) {
    _foods = foods;
    _exercises = exercises;
    _total = total;
  }

  Counts.fromJson(dynamic json) {
    _foods = json['foods'];
    _exercises = json['exercises'];
    _total = json['total'];
  }
  dynamic _foods;
  dynamic _exercises;
  dynamic _total;
  Counts copyWith({
    dynamic foods,
    dynamic exercises,
    dynamic total,
  }) =>
      Counts(
        foods: foods ?? _foods,
        exercises: exercises ?? _exercises,
        total: total ?? _total,
      );
  dynamic get foods => _foods;
  dynamic get exercises => _exercises;
  dynamic get total => _total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['foods'] = _foods;
    map['exercises'] = _exercises;
    map['total'] = _total;
    return map;
  }
}

/// type : "food"
/// id : "699acce2fe7818a9e3f82a2b"
/// date : "2026-02-22T00:00:00.000Z"
/// time : "01:31 PM"
/// title : "chicken"
/// mealType : "lunch"
/// servings : 1
/// subtitle : "lunch • 1 serving"
/// calories : 200
/// macros : {"protein_g":1,"carbs_g":1,"fats_g":11}
/// createdAt : "2026-02-22T09:31:14.559Z"

class Activities {
  Activities({
    dynamic type,
    dynamic id,
    dynamic date,
    dynamic time,
    dynamic title,
    dynamic mealType,
    dynamic servings,
    dynamic subtitle,
    dynamic exerciseType,
    dynamic intensity,
    dynamic durationMin,
    dynamic calories,
    Macros? macros,
    dynamic createdAt,
  }) {
    _type = type;
    _id = id;
    _date = date;
    _time = time;
    _title = title;
    _mealType = mealType;
    _servings = servings;
    _subtitle = subtitle;
    _exerciseType = exerciseType;
    _intensity = intensity;
    _durationMin = durationMin;
    _calories = calories;
    _macros = macros;
    _createdAt = createdAt;
  }

  bool get isFood => type == 'food';
  bool get isExercise => type == 'exercise';

  Activities.fromJson(dynamic json) {
    _type = json['type'];
    _id = json['id'];
    _date = json['date'];
    _time = json['time'];
    _title = json['title'];
    _mealType = json['mealType'];
    _servings = json['servings'];
    _subtitle = json['subtitle'];
    _exerciseType = json['exerciseType'];
    _intensity = json['intensity'];
    _durationMin = json['durationMin'];
    _calories = json['calories'];
    _macros = json['macros'] != null ? Macros.fromJson(json['macros']) : null;
    _createdAt = json['createdAt'];
  }
  dynamic _type;
  dynamic _id;
  dynamic _date;
  dynamic _time;
  dynamic _title;
  dynamic _mealType;
  dynamic _servings;
  dynamic _subtitle;
  dynamic _exerciseType;
  dynamic _intensity;
  dynamic _durationMin;
  dynamic _calories;
  Macros? _macros;
  dynamic _createdAt;
  Activities copyWith({
    dynamic type,
    dynamic id,
    dynamic date,
    dynamic time,
    dynamic title,
    dynamic mealType,
    dynamic servings,
    dynamic subtitle,
    dynamic exerciseType,
    dynamic intensity,
    dynamic durationMin,
    dynamic calories,
    Macros? macros,
    dynamic createdAt,
  }) =>
      Activities(
        type: type ?? _type,
        id: id ?? _id,
        date: date ?? _date,
        time: time ?? _time,
        title: title ?? _title,
        mealType: mealType ?? _mealType,
        servings: servings ?? _servings,
        subtitle: subtitle ?? _subtitle,
        exerciseType: exerciseType ?? _exerciseType,
        intensity: intensity ?? _intensity,
        durationMin: durationMin ?? _durationMin,
        calories: calories ?? _calories,
        macros: macros ?? _macros,
        createdAt: createdAt ?? _createdAt,
      );
  dynamic get type => _type;
  dynamic get id => _id;
  dynamic get date => _date;
  dynamic get time => _time;
  dynamic get title => _title;
  dynamic get mealType => _mealType;
  dynamic get servings => _servings;
  dynamic get subtitle => _subtitle;
  dynamic get exerciseType => _exerciseType;
  dynamic get intensity => _intensity;
  dynamic get durationMin => _durationMin;
  dynamic get calories => _calories;
  Macros? get macros => _macros;
  dynamic get createdAt => _createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = _type;
    map['id'] = _id;
    map['date'] = _date;
    map['time'] = _time;
    map['title'] = _title;
    map['mealType'] = _mealType;
    map['servings'] = _servings;
    map['subtitle'] = _subtitle;
    map['exerciseType'] = _exerciseType;
    map['intensity'] = _intensity;
    map['durationMin'] = _durationMin;
    map['calories'] = _calories;
    if (_macros != null) {
      map['macros'] = _macros?.toJson();
    }
    map['createdAt'] = _createdAt;
    return map;
  }
}

/// protein_g : 1
/// carbs_g : 1
/// fats_g : 11

class Macros {
  Macros({
    dynamic proteinG,
    dynamic carbsG,
    dynamic fatsG,
  }) {
    _proteinG = proteinG;
    _carbsG = carbsG;
    _fatsG = fatsG;
  }

  Macros.fromJson(dynamic json) {
    _proteinG = json['protein_g'];
    _carbsG = json['carbs_g'];
    _fatsG = json['fats_g'];
  }
  dynamic _proteinG;
  dynamic _carbsG;
  dynamic _fatsG;
  Macros copyWith({
    dynamic proteinG,
    dynamic carbsG,
    dynamic fatsG,
  }) =>
      Macros(
        proteinG: proteinG ?? _proteinG,
        carbsG: carbsG ?? _carbsG,
        fatsG: fatsG ?? _fatsG,
      );
  dynamic get proteinG => _proteinG;
  dynamic get carbsG => _carbsG;
  dynamic get fatsG => _fatsG;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['protein_g'] = _proteinG;
    map['carbs_g'] = _carbsG;
    map['fats_g'] = _fatsG;
    return map;
  }
}
