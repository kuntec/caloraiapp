class UserRegisterData {
  UserRegisterData({
    dynamic token,
    dynamic status,
    dynamic message,
    User? user,
  }) {
    _token = token;
    _status = status;
    _message = message;
    _user = user;
  }

  UserRegisterData.fromJson(dynamic json) {
    _token = json['token'];
    _status = json['status'];
    _message = json['message'];
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  dynamic _token;
  dynamic _status;
  dynamic _message;
  User? _user;
  UserRegisterData copyWith({
    dynamic token,
    dynamic status,
    dynamic message,
    User? user,
  }) =>
      UserRegisterData(
        token: token ?? _token,
        status: status ?? _status,
        message: message ?? _message,
        user: user ?? _user,
      );
  dynamic get token => _token;
  dynamic get status => _status;
  dynamic get message => _message;
  User? get user => _user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = _token;
    map['status'] = _status;
    map['message'] = _message;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    return map;
  }
}

class User {
  User({
    dynamic id,
    dynamic email,
    Profile? profile,
    DailyTargets? dailyTargets,
    Streaks? streaks,
    List<dynamic>? badgesEarned,
  }) {
    _id = id;
    _email = email;
    _profile = profile;
    _dailyTargets = dailyTargets;
    _streaks = streaks;
    _badgesEarned = badgesEarned;
  }

  User.fromJson(dynamic json) {
    _id = json['_id'];
    _email = json['email'];
    _profile =
        json['profile'] != null ? Profile.fromJson(json['profile']) : null;
    _dailyTargets = json['dailyTargets'] != null
        ? DailyTargets.fromJson(json['dailyTargets'])
        : null;
    _streaks =
        json['streaks'] != null ? Streaks.fromJson(json['streaks']) : null;
    if (json['badgesEarned'] != null) {
      _badgesEarned = [];
      json['badgesEarned'].forEach((v) {
        _badgesEarned?.add(v);
      });
    }
  }
  dynamic _id;
  dynamic _email;
  Profile? _profile;
  DailyTargets? _dailyTargets;
  Streaks? _streaks;
  List<dynamic>? _badgesEarned;
  User copyWith({
    dynamic id,
    dynamic email,
    Profile? profile,
    DailyTargets? dailyTargets,
    Streaks? streaks,
    List<dynamic>? badgesEarned,
  }) =>
      User(
        id: id ?? _id,
        email: email ?? _email,
        profile: profile ?? _profile,
        dailyTargets: dailyTargets ?? _dailyTargets,
        streaks: streaks ?? _streaks,
        badgesEarned: badgesEarned ?? _badgesEarned,
      );
  dynamic get id => _id;
  dynamic get email => _email;
  Profile? get profile => _profile;
  DailyTargets? get dailyTargets => _dailyTargets;
  Streaks? get streaks => _streaks;
  List<dynamic>? get badgesEarned => _badgesEarned;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['email'] = _email;
    if (_profile != null) {
      map['profile'] = _profile?.toJson();
    }
    if (_dailyTargets != null) {
      map['dailyTargets'] = _dailyTargets?.toJson();
    }
    if (_streaks != null) {
      map['streaks'] = _streaks?.toJson();
    }
    if (_badgesEarned != null) {
      map['badgesEarned'] = _badgesEarned?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// dailyLog : {"current":0,"longest":0}
/// goalAdherence : {"current":0,"longest":0}

class Streaks {
  Streaks({
    DailyLog? dailyLog,
    GoalAdherence? goalAdherence,
  }) {
    _dailyLog = dailyLog;
    _goalAdherence = goalAdherence;
  }

  Streaks.fromJson(dynamic json) {
    _dailyLog =
        json['dailyLog'] != null ? DailyLog.fromJson(json['dailyLog']) : null;
    _goalAdherence = json['goalAdherence'] != null
        ? GoalAdherence.fromJson(json['goalAdherence'])
        : null;
  }
  DailyLog? _dailyLog;
  GoalAdherence? _goalAdherence;
  Streaks copyWith({
    DailyLog? dailyLog,
    GoalAdherence? goalAdherence,
  }) =>
      Streaks(
        dailyLog: dailyLog ?? _dailyLog,
        goalAdherence: goalAdherence ?? _goalAdherence,
      );
  DailyLog? get dailyLog => _dailyLog;
  GoalAdherence? get goalAdherence => _goalAdherence;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_dailyLog != null) {
      map['dailyLog'] = _dailyLog?.toJson();
    }
    if (_goalAdherence != null) {
      map['goalAdherence'] = _goalAdherence?.toJson();
    }
    return map;
  }
}

/// current : 0
/// longest : 0

class GoalAdherence {
  GoalAdherence({
    dynamic current,
    dynamic longest,
  }) {
    _current = current;
    _longest = longest;
  }

  GoalAdherence.fromJson(dynamic json) {
    _current = json['current'];
    _longest = json['longest'];
  }
  dynamic _current;
  dynamic _longest;
  GoalAdherence copyWith({
    dynamic current,
    dynamic longest,
  }) =>
      GoalAdherence(
        current: current ?? _current,
        longest: longest ?? _longest,
      );
  dynamic get current => _current;
  dynamic get longest => _longest;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current'] = _current;
    map['longest'] = _longest;
    return map;
  }
}

/// current : 0
/// longest : 0

class DailyLog {
  DailyLog({
    dynamic current,
    dynamic longest,
  }) {
    _current = current;
    _longest = longest;
  }

  DailyLog.fromJson(dynamic json) {
    _current = json['current'];
    _longest = json['longest'];
  }
  dynamic _current;
  dynamic _longest;
  DailyLog copyWith({
    dynamic current,
    dynamic longest,
  }) =>
      DailyLog(
        current: current ?? _current,
        longest: longest ?? _longest,
      );
  dynamic get current => _current;
  dynamic get longest => _longest;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current'] = _current;
    map['longest'] = _longest;
    return map;
  }
}

/// targetCalories : 2000
/// targetProteinG : 100
/// targetCarbsG : 250
/// targetFatsG : 70
/// targetFiberG : 25
/// targetSugarG : 30
/// targetSodiumMg : 2300
/// targetPotassiumMg : 3500
/// targetCholesterolMg : 300
/// targetVitaminA_mcg : 0
/// targetVitaminC_mg : 0
/// targetCalcium_mg : 0
/// targetIron_mg : 0

class DailyTargets {
  DailyTargets({
    dynamic targetCalories,
    dynamic targetProteinG,
    dynamic targetCarbsG,
    dynamic targetFatsG,
    dynamic targetFiberG,
    dynamic targetSugarG,
    dynamic targetSodiumMg,
    dynamic targetPotassiumMg,
    dynamic targetCholesterolMg,
    dynamic targetVitaminAMcg,
    dynamic targetVitaminCMg,
    dynamic targetCalciumMg,
    dynamic targetIronMg,
  }) {
    _targetCalories = targetCalories;
    _targetProteinG = targetProteinG;
    _targetCarbsG = targetCarbsG;
    _targetFatsG = targetFatsG;
    _targetFiberG = targetFiberG;
    _targetSugarG = targetSugarG;
    _targetSodiumMg = targetSodiumMg;
    _targetPotassiumMg = targetPotassiumMg;
    _targetCholesterolMg = targetCholesterolMg;
    _targetVitaminAMcg = targetVitaminAMcg;
    _targetVitaminCMg = targetVitaminCMg;
    _targetCalciumMg = targetCalciumMg;
    _targetIronMg = targetIronMg;
  }

  DailyTargets.fromJson(dynamic json) {
    _targetCalories = json['targetCalories'];
    _targetProteinG = json['targetProteinG'];
    _targetCarbsG = json['targetCarbsG'];
    _targetFatsG = json['targetFatsG'];
    _targetFiberG = json['targetFiberG'];
    _targetSugarG = json['targetSugarG'];
    _targetSodiumMg = json['targetSodiumMg'];
    _targetPotassiumMg = json['targetPotassiumMg'];
    _targetCholesterolMg = json['targetCholesterolMg'];
    _targetVitaminAMcg = json['targetVitaminA_mcg'];
    _targetVitaminCMg = json['targetVitaminC_mg'];
    _targetCalciumMg = json['targetCalcium_mg'];
    _targetIronMg = json['targetIron_mg'];
  }
  dynamic _targetCalories;
  dynamic _targetProteinG;
  dynamic _targetCarbsG;
  dynamic _targetFatsG;
  dynamic _targetFiberG;
  dynamic _targetSugarG;
  dynamic _targetSodiumMg;
  dynamic _targetPotassiumMg;
  dynamic _targetCholesterolMg;
  dynamic _targetVitaminAMcg;
  dynamic _targetVitaminCMg;
  dynamic _targetCalciumMg;
  dynamic _targetIronMg;
  DailyTargets copyWith({
    dynamic targetCalories,
    dynamic targetProteinG,
    dynamic targetCarbsG,
    dynamic targetFatsG,
    dynamic targetFiberG,
    dynamic targetSugarG,
    dynamic targetSodiumMg,
    dynamic targetPotassiumMg,
    dynamic targetCholesterolMg,
    dynamic targetVitaminAMcg,
    dynamic targetVitaminCMg,
    dynamic targetCalciumMg,
    dynamic targetIronMg,
  }) =>
      DailyTargets(
        targetCalories: targetCalories ?? _targetCalories,
        targetProteinG: targetProteinG ?? _targetProteinG,
        targetCarbsG: targetCarbsG ?? _targetCarbsG,
        targetFatsG: targetFatsG ?? _targetFatsG,
        targetFiberG: targetFiberG ?? _targetFiberG,
        targetSugarG: targetSugarG ?? _targetSugarG,
        targetSodiumMg: targetSodiumMg ?? _targetSodiumMg,
        targetPotassiumMg: targetPotassiumMg ?? _targetPotassiumMg,
        targetCholesterolMg: targetCholesterolMg ?? _targetCholesterolMg,
        targetVitaminAMcg: targetVitaminAMcg ?? _targetVitaminAMcg,
        targetVitaminCMg: targetVitaminCMg ?? _targetVitaminCMg,
        targetCalciumMg: targetCalciumMg ?? _targetCalciumMg,
        targetIronMg: targetIronMg ?? _targetIronMg,
      );
  dynamic get targetCalories => _targetCalories;
  dynamic get targetProteinG => _targetProteinG;
  dynamic get targetCarbsG => _targetCarbsG;
  dynamic get targetFatsG => _targetFatsG;
  dynamic get targetFiberG => _targetFiberG;
  dynamic get targetSugarG => _targetSugarG;
  dynamic get targetSodiumMg => _targetSodiumMg;
  dynamic get targetPotassiumMg => _targetPotassiumMg;
  dynamic get targetCholesterolMg => _targetCholesterolMg;
  dynamic get targetVitaminAMcg => _targetVitaminAMcg;
  dynamic get targetVitaminCMg => _targetVitaminCMg;
  dynamic get targetCalciumMg => _targetCalciumMg;
  dynamic get targetIronMg => _targetIronMg;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['targetCalories'] = _targetCalories;
    map['targetProteinG'] = _targetProteinG;
    map['targetCarbsG'] = _targetCarbsG;
    map['targetFatsG'] = _targetFatsG;
    map['targetFiberG'] = _targetFiberG;
    map['targetSugarG'] = _targetSugarG;
    map['targetSodiumMg'] = _targetSodiumMg;
    map['targetPotassiumMg'] = _targetPotassiumMg;
    map['targetCholesterolMg'] = _targetCholesterolMg;
    map['targetVitaminA_mcg'] = _targetVitaminAMcg;
    map['targetVitaminC_mg'] = _targetVitaminCMg;
    map['targetCalcium_mg'] = _targetCalciumMg;
    map['targetIron_mg'] = _targetIronMg;
    return map;
  }
}

/// fullName : "Tausif42 Saiyed"
/// dateOfBirth : "1989-06-15T00:00:00.000Z"
/// gender : "male"
/// heightCm : 175
/// weightKg : 82
/// activityLevel : "moderate"
/// goalType : "weight_loss"
/// dailyStepGoal : 10000
/// weightGoal : {"isAchieved":false,"weeklyProgress":{"avgLossPerWeekKg":0,"remainingWeeks":0}}

class Profile {
  Profile({
    dynamic fullName,
    dynamic dateOfBirth,
    dynamic gender,
    dynamic heightCm,
    dynamic weightKg,
    dynamic activityLevel,
    dynamic goalType,
    dynamic dailyStepGoal,
    WeightGoal? weightGoal,
  }) {
    _fullName = fullName;
    _dateOfBirth = dateOfBirth;
    _gender = gender;
    _heightCm = heightCm;
    _weightKg = weightKg;
    _activityLevel = activityLevel;
    _goalType = goalType;
    _dailyStepGoal = dailyStepGoal;
    _weightGoal = weightGoal;
  }

  Profile.fromJson(dynamic json) {
    _fullName = json['fullName'];
    _dateOfBirth = json['dateOfBirth'];
    _gender = json['gender'];
    _heightCm = json['heightCm'];
    _weightKg = json['weightKg'];
    _activityLevel = json['activityLevel'];
    _goalType = json['goalType'];
    _dailyStepGoal = json['dailyStepGoal'];
    _weightGoal = json['weightGoal'] != null
        ? WeightGoal.fromJson(json['weightGoal'])
        : null;
  }
  dynamic _fullName;
  dynamic _dateOfBirth;
  dynamic _gender;
  dynamic _heightCm;
  dynamic _weightKg;
  dynamic _activityLevel;
  dynamic _goalType;
  dynamic _dailyStepGoal;
  WeightGoal? _weightGoal;
  Profile copyWith({
    dynamic fullName,
    dynamic dateOfBirth,
    dynamic gender,
    dynamic heightCm,
    dynamic weightKg,
    dynamic activityLevel,
    dynamic goalType,
    dynamic dailyStepGoal,
    WeightGoal? weightGoal,
  }) =>
      Profile(
        fullName: fullName ?? _fullName,
        dateOfBirth: dateOfBirth ?? _dateOfBirth,
        gender: gender ?? _gender,
        heightCm: heightCm ?? _heightCm,
        weightKg: weightKg ?? _weightKg,
        activityLevel: activityLevel ?? _activityLevel,
        goalType: goalType ?? _goalType,
        dailyStepGoal: dailyStepGoal ?? _dailyStepGoal,
        weightGoal: weightGoal ?? _weightGoal,
      );
  dynamic get fullName => _fullName;
  dynamic get dateOfBirth => _dateOfBirth;
  dynamic get gender => _gender;
  dynamic get heightCm => _heightCm;
  dynamic get weightKg => _weightKg;
  dynamic get activityLevel => _activityLevel;
  dynamic get goalType => _goalType;
  dynamic get dailyStepGoal => _dailyStepGoal;
  WeightGoal? get weightGoal => _weightGoal;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['fullName'] = _fullName;
    map['dateOfBirth'] = _dateOfBirth;
    map['gender'] = _gender;
    map['heightCm'] = _heightCm;
    map['weightKg'] = _weightKg;
    map['activityLevel'] = _activityLevel;
    map['goalType'] = _goalType;
    map['dailyStepGoal'] = _dailyStepGoal;
    if (_weightGoal != null) {
      map['weightGoal'] = _weightGoal?.toJson();
    }
    return map;
  }
}

/// isAchieved : false
/// weeklyProgress : {"avgLossPerWeekKg":0,"remainingWeeks":0}

class WeightGoal {
  WeightGoal({
    bool? isAchieved,
    WeeklyProgress? weeklyProgress,
  }) {
    _isAchieved = isAchieved;
    _weeklyProgress = weeklyProgress;
  }

  WeightGoal.fromJson(dynamic json) {
    _isAchieved = json['isAchieved'];
    _weeklyProgress = json['weeklyProgress'] != null
        ? WeeklyProgress.fromJson(json['weeklyProgress'])
        : null;
  }
  bool? _isAchieved;
  WeeklyProgress? _weeklyProgress;
  WeightGoal copyWith({
    bool? isAchieved,
    WeeklyProgress? weeklyProgress,
  }) =>
      WeightGoal(
        isAchieved: isAchieved ?? _isAchieved,
        weeklyProgress: weeklyProgress ?? _weeklyProgress,
      );
  bool? get isAchieved => _isAchieved;
  WeeklyProgress? get weeklyProgress => _weeklyProgress;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['isAchieved'] = _isAchieved;
    if (_weeklyProgress != null) {
      map['weeklyProgress'] = _weeklyProgress?.toJson();
    }
    return map;
  }
}

/// avgLossPerWeekKg : 0
/// remainingWeeks : 0

class WeeklyProgress {
  WeeklyProgress({
    dynamic avgLossPerWeekKg,
    dynamic remainingWeeks,
  }) {
    _avgLossPerWeekKg = avgLossPerWeekKg;
    _remainingWeeks = remainingWeeks;
  }

  WeeklyProgress.fromJson(dynamic json) {
    _avgLossPerWeekKg = json['avgLossPerWeekKg'];
    _remainingWeeks = json['remainingWeeks'];
  }
  dynamic _avgLossPerWeekKg;
  dynamic _remainingWeeks;
  WeeklyProgress copyWith({
    dynamic avgLossPerWeekKg,
    dynamic remainingWeeks,
  }) =>
      WeeklyProgress(
        avgLossPerWeekKg: avgLossPerWeekKg ?? _avgLossPerWeekKg,
        remainingWeeks: remainingWeeks ?? _remainingWeeks,
      );
  dynamic get avgLossPerWeekKg => _avgLossPerWeekKg;
  dynamic get remainingWeeks => _remainingWeeks;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['avgLossPerWeekKg'] = _avgLossPerWeekKg;
    map['remainingWeeks'] = _remainingWeeks;
    return map;
  }
}
