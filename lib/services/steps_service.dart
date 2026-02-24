import 'package:health/health.dart';

class StepsService {
  final Health _health = Health();

  Future<bool> connectAndAuthorize() async {
    // Configure to use Health Connect on Android (health package handles internally)
    final types = <HealthDataType>[HealthDataType.STEPS];
    final permissions = <HealthDataAccess>[HealthDataAccess.READ];

    // Request authorization: this should open Health Connect permission UI
    final granted = await _health.requestAuthorization(
      types,
      permissions: permissions,
    );

    return granted;
  }

  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day); // local start of day
    final end = now;

    // This is the simplest total steps call
    final steps = await _health.getTotalStepsInInterval(start, end);
    return steps ?? 0;
  }
}
