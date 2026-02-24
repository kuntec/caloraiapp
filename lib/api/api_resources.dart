class APIResource {
  static const String BASE_URL = "http://10.10.3.29:8080/api/";

  static const String LOGIN = "${BASE_URL}auth/login";
  static const String REGISTER = "${BASE_URL}auth/register";
  static const String DAILY_METRICS_TODAY = "${BASE_URL}daily-metrics/today";
  static const String DAILY_METRICS_DATE = "${BASE_URL}daily-metrics?date=";
  static const String UPDATE_WATER_INTAKE = "${BASE_URL}daily-metrics?date=";
  static const String ADD_EXERCISE_LOG = "${BASE_URL}exercises";
  static const String ADD_FOOD = "${BASE_URL}foods";
  static const String SEARCH_FOOD = "${BASE_URL}foods/search";
  static const String ADD_FOOD_LOG = "${BASE_URL}food-logs";
  static const String RECENT_ACTIVITY = "${BASE_URL}activity/recent?date=";
  static const String DELETE_FOOD_LOG = "${BASE_URL}food-logs/";
  static const String DELETE_EXERCISE_LOG = "${BASE_URL}exercises/";
}
