import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/request_book_model.dart';
import '../repository/request_book_repository.dart';

class RequestBookProvider extends ChangeNotifier {
  final RequestBookRepository _repository;

  RequestBookProvider({required RequestBookRepository repository})
      : _repository = repository;

  bool loading = false;
  String? error;

  List<RequestBookModel> myRequests = [];

  /// إنشاء طلب كتاب
  Future<bool> createRequest({
    required String title,
    required String description,
    required String bookType, // free | paid
    int? price,
    required File file,
  }) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _repository.createRequestBook(
        title: title,
        description: description,
        bookType: bookType,
        price: price,
        file: file,
      );

      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      loading = false;
      error = "فشل إرسال طلب الكتاب";
      notifyListeners();
      return false;
    }
  }

  /// جلب طلبات المستخدم
  Future<void> fetchMyRequests() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      myRequests = await _repository.fetchMyRequests();

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = "فشل تحميل الطلبات";
      notifyListeners();
    }
  }
}
