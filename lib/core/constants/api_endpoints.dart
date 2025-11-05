class ApiEndpoints {
  static const String baseUrl = "http://192.168.0.103:8000/api";

  // 🔐 Auth
  static const String register = "/auth/register";
  static const String login = "/auth/login";
  static const String logout = "/auth/logout";

  // 👤 User
  static const String currentUser = "/users/me";
  static const String updateCurrentUser = "/users/me";

  // ⭐ Points
  static const String userPoints = "/users/points";

  // 📚 Quotes
  static const String quotes = "/quotes"; // GET → جميع الاقتباسات | POST → نشر اقتباس جديد
  static const String saveQuote = "/quotes/save"; // POST → حفظ اقتباس للمستخدم

  // ✅ Getters
  static String get getCurrentUser => baseUrl + currentUser;
  static String get getUpdateCurrentUser => baseUrl + updateCurrentUser;
  static String get getUserPoints => baseUrl + userPoints;

  // 📖 Quotes Getters
  static String get getQuotes => baseUrl + quotes;
  static String get postSaveQuote => baseUrl + saveQuote;
}
