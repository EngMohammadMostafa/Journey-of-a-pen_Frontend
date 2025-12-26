import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PrefsHelper {
  static const String _keyHasChosenInterests = 'has_chosen_interests';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyDownloadedBooks = 'downloaded_books';
  static const String _keyPurchasedBooks = 'purchased_books';

  /// 🔹 حفظ أن المستخدم اختار اهتماماته
  static Future<void> setHasChosenInterests(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasChosenInterests, value);
  }

  /// 🔹 التحقق هل المستخدم اختار الاهتمامات مسبقًا
  static Future<bool> hasChosenInterests() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasChosenInterests) ?? false;
  }

  /// 🔹 حفظ التوكن بعد تسجيل الدخول
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
  }

  /// 📥 جلب التوكن
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  /// 🧹 حذف التوكن
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
  }

  /// 💾 حفظ الـ ID الخاص بالمستخدم
  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, id);
  }

  /// 📤 جلب الـ ID الخاص بالمستخدم
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// 🧹 حذف بيانات المستخدم بالكامل
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyHasChosenInterests);
    await prefs.remove(_keyDownloadedBooks);
    await prefs.remove(_keyPurchasedBooks);
  }

  // =====================================
  // 🔹 تخزين وإدارة الكتب محليًا
  // =====================================

  /// حفظ قائمة IDs الكتب المحملة
  static Future<void> setDownloadedBookIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyDownloadedBooks,
      ids.map((e) => e.toString()).toList(),
    );
  }

  /// جلب قائمة IDs الكتب المحملة
  static Future<List<int>> getDownloadedBookIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyDownloadedBooks) ?? [];
    return list.map(int.parse).toList();
  }

  /// حفظ قائمة IDs الكتب المشتراة
  static Future<void> setPurchasedBookIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyPurchasedBooks,
      ids.map((e) => e.toString()).toList(),
    );
  }

  /// جلب قائمة IDs الكتب المشتراة
  static Future<List<int>> getPurchasedBookIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyPurchasedBooks) ?? [];
    return list.map(int.parse).toList();
  }

  // =====================================
  // ✅ إضافات آمنة (بدون كسر أي شيء)
  // =====================================

  /// 🔐 هل الكتاب مشتَرى؟
  static Future<bool> isBookPurchased(int bookId) async {
    final ids = await getPurchasedBookIds();
    return ids.contains(bookId);
  }

  /// 📥 هل الكتاب محمَّل؟
  static Future<bool> isBookDownloaded(int bookId) async {
    final ids = await getDownloadedBookIds();
    return ids.contains(bookId);
  }

  /// ➕ إضافة كتاب مشتَرى (بدون تكرار)
  static Future<void> addPurchasedBook(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyPurchasedBooks) ?? [];

    if (!list.contains(bookId.toString())) {
      list.add(bookId.toString());
      await prefs.setStringList(_keyPurchasedBooks, list);
    }
  }

  /// ➕ إضافة كتاب محمَّل (بدون تكرار)
  static Future<void> addDownloadedBook(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyDownloadedBooks) ?? [];

    if (!list.contains(bookId.toString())) {
      list.add(bookId.toString());
      await prefs.setStringList(_keyDownloadedBooks, list);
    }
  }

  // =====================================
  // 📁 ملفات الكتب
  // =====================================

  /// مسار تخزين ملفات الكتب
  static Future<String> getBooksDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final booksDir = Directory('${dir.path}/books');
    if (!booksDir.existsSync()) {
      booksDir.createSync(recursive: true);
    }
    return booksDir.path;
  }

  /// حفظ محتوى الكتاب محليًا
  static Future<File> saveBookContent(int bookId, List<int> bytes) async {
    final path = await getBooksDirectory();
    final file = File('$path/book_$bookId.pdf');
    return file.writeAsBytes(bytes);
  }

  /// قراءة محتوى الكتاب محليًا
  static Future<File?> getBookFile(int bookId) async {
    final path = await getBooksDirectory();
    final file = File('$path/book_$bookId.pdf');
    if (file.existsSync()) return file;
    return null;
  }
}
