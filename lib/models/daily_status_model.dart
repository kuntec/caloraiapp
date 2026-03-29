class DailyStatus {
  final bool hasFoodLog;
  final bool hasExerciseLog;
  final bool waterGoalMet;
  final bool stepsGoalMet;
  final bool isCompletedDay;

  DailyStatus({
    required this.hasFoodLog,
    required this.hasExerciseLog,
    required this.waterGoalMet,
    required this.stepsGoalMet,
    required this.isCompletedDay,
  });

  factory DailyStatus.fromJson(Map<String, dynamic> json) {
    return DailyStatus(
      hasFoodLog: json['hasFoodLog'] ?? false,
      hasExerciseLog: json['hasExerciseLog'] ?? false,
      waterGoalMet: json['waterGoalMet'] ?? false,
      stepsGoalMet: json['stepsGoalMet'] ?? false,
      isCompletedDay: json['isCompletedDay'] ?? false,
    );
  }
}
