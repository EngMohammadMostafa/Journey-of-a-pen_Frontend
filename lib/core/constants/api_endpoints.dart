class ApiEndpoints {
  static const String baseUrl = "http://192.168.0.105:8000/api";

  //  Auth
  static const String register = "/auth/register";
  static const String login = "/auth/login";
  static const String logout = "/auth/logout";

  //  User
  static const String currentUser = "/users/me";
  static const String updateCurrentUser = "/users/me";

  //  Points
  static const String userPoints = "/users/points";

  //  Quotes
  static const String quotes = "/quotes"; // GET جميع الاقتباسات | POST نشر اقتباس جديد
  static const String saveQuote = "/quotes/save"; // POST → حفظ اقتباس للمستخدم

  //  Books & Categories
  static const String categories = "/categories"; // GET  جميع الأقسام
  static String booksByCategory(int categoryId) => "/categories/$categoryId/books"; // GET الكتب حسب القسم
  static const String allBooks = "/books"; // GET  جميع الكتب
  static String bookDetails(int bookId) => "/books/$bookId"; // GET  تفاصيل كتاب
  static String downloadBook(int bookId) => "/books/$bookId/download"; // POST رابط تحميل الكتاب
}
