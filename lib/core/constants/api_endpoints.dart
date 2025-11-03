class ApiEndpoints {
  // استبدل baseUrl بعنوان السيرفر المحلي
  static const String baseUrl = "http://192.168.0.103:8000/api";

  // 🔐 Auth
  static const String register = "/auth/register";
  static const String login = "/auth/login";
  static const String logout = "/auth/logout";

  // 👤 User
  static const String currentUser = "/users/me"; // GET: بيانات المستخدم الحالي
  static const String updateCurrentUser = "/users/me"; // PUT: تحديث بيانات المستخدم

  // ⭐ Points
  static const String userPoints = "/users/points"; // GET: عدد النقاط الحالية

  // ✅ Getter لعنوان المستخدم الحالي
  static String get getCurrentUser => baseUrl + currentUser;

  // مثال getter لتحديث المستخدم
  static String get getUpdateCurrentUser => baseUrl + updateCurrentUser;

  // مثال getter لنقاط المستخدم
  static String get getUserPoints => baseUrl + userPoints;
}
