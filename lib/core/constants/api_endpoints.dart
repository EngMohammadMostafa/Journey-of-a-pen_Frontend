class ApiEndpoints {
  static const String baseUrl = "http://192.168.0.105:8000/api";

  //  Auth
  static const String register = "/auth/register";
  static const String login = "/auth/login";
  static const String logout = "/auth/logout";

  //  User
  static const String currentUser = "/users/me";
  static const String updateCurrentUser = "/users/me";
  static const String changePassword = "/users/me/change-password";

  //  Points / Repoints
  static const String userPoints = "/users/points";

  //  Quotes
  static const String quotes = "/quotes"; // GET جميع الاقتباسات | POST نشر اقتباس جديد
  static const String saveQuote = "/quotes/save"; // POST → حفظ اقتباس للمستخدم

  //  Books & Categories
  static const String categories = "/categories"; // GET جميع الأقسام
  static String booksByCategory(int categoryId) => "/categories/$categoryId/books"; // GET الكتب حسب القسم
  static const String allBooks = "/books"; // GET جميع الكتب
  static String bookDetails(int bookId) => "/books/$bookId"; // GET تفاصيل كتاب
  static String downloadBook(int bookId) => "/books/$bookId/download"; // POST رابط تحميل الكتاب
  static const String userBooks = "/me/books"; // كتب المستخدم الحالي
  static String bookWithLikes(int bookId) => "/books/$bookId/with-likes"; // تفاصيل كتاب + عدد likes
  static String serveDownload(int bookId, int userId) => "/books/$bookId/serve-download/$userId"; // رابط تحميل مؤقت

  //  Questions & Answers
  static String bookQuestions(int bookId) => "/books/$bookId/questions"; // GET أسئلة الكتاب
  static String startBookSession(int bookId) => "/books/$bookId/session/start"; // POST بدء جلسة إجابة
  static String recordAnswer(int bookId) => "/books/$bookId/session/answer"; // POST تسجيل إجابة
  static String submitAnswers(int bookId) => "/books/$bookId/session/submit"; // POST إنهاء الجلسة
  static String exitSession(int bookId) => "/books/$bookId/session/exit"; // POST الخروج من الجلسة

  //  Rewards
  static const String rewards = "/rewards"; // GET كل المكافآت | POST استبدال مكافأة
}
