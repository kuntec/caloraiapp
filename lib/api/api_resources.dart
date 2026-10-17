class APIResource {
//  static const String BASE_URL = "http://192.168.70.1:8080/api/";
  static const String BASE_URL = "https://calroai-backend.vercel.app/api/";

  static const String LOGIN = "${BASE_URL}auth/login";
  static const String REGISTER = "${BASE_URL}auth/register";
  static const String DAILY_METRICS_TODAY = "${BASE_URL}daily-metrics/today";
  static const String DAILY_METRICS_DATE = "${BASE_URL}daily-metrics?date=";
  static const String UPDATE_WATER_INTAKE = "${BASE_URL}daily-metrics?date=";
  static const String ADD_EXERCISE_LOG = "${BASE_URL}exercises";
  static const String ADD_FOOD = "${BASE_URL}foods";
  static const String SEARCH_FOOD = "${BASE_URL}foods/search?q=";
  static const String SEARCH_MY_FOOD = "${BASE_URL}foods/search?mine=true&q=";
  static const String ADD_FOOD_LOG = "${BASE_URL}food-logs";
  static const String RECENT_ACTIVITY = "${BASE_URL}activity/recent?date=";
  static const String DELETE_FOOD_LOG = "${BASE_URL}food-logs/";
  static const String DELETE_EXERCISE_LOG = "${BASE_URL}exercises/";
  static const String STREAK_SUMMARY = "${BASE_URL}streaks/summary";

  static const String ADD_MEAL_PROFILE = "${BASE_URL}meal-plan/profile";
  static const String GENERATE_MEAL_PLAN = "${BASE_URL}meal-plan/generate";
  static const String ALL_MEAL_PLANS = "${BASE_URL}meal-plan/plans";

  static const String DELETE_ACCOUNT = "${BASE_URL}auth/delete-account";
  static const String AUTH_ME = "${BASE_URL}auth/me";
  static const String SOCIAL_LOGIN = "${BASE_URL}auth/social-login";
  static const String UPDATE_PROFILE = "${BASE_URL}users/me";
  static const String START_TRIAL = "${BASE_URL}auth/start-trial";
  static const String TRIAL_STATUS = "${BASE_URL}auth/trial-status";
  static const String DAILY_METRICS_RANGE = "${BASE_URL}daily-metrics/range";
}
