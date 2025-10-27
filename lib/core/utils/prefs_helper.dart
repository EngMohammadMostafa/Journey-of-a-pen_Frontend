import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  static const String _keyHasChosenInterests = 'has_chosen_interests';
  static const String _keyAuthToken = 'auth_token'; // 🟩 مفتاح حفظ التوكن
  static const String _keyUserId = 'user_id';       // 🟩 مفتاح حفظ ID المستخدم

  /// 🔹 يحفظ أن المستخدم اختار اهتماماته
  static Future<void> setHasChosenInterests(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasChosenInterests, value);
  }

  /// 🔹 يتحقق هل المستخدم اختار الاهتمامات مسبقًا أم لا
  static Future<bool> hasChosenInterests() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasChosenInterests) ?? false;
  }

  /// 🔹 يمكن استخدامها لإعادة التعيين (للاختبار مثلاً)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasChosenInterests);
  }

  // =====================================
  // 🟦 الإضافات الخاصة بتخزين بيانات المستخدم
  // =====================================

  /// 🔐 حفظ التوكن بعد تسجيل الدخول
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
  }

  /// 📥 جلب التوكن عند الحاجة (مثل صفحة البروفايل)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  /// 🧹 حذف التوكن عند تسجيل الخروج
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

  /// 🧹 حذف بيانات المستخدم بالكامل (عند تسجيل الخروج)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyHasChosenInterests);
  }
}
