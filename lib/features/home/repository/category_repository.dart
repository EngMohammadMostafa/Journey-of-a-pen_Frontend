import 'package:flutter/foundation.dart';
import '../data/category_service.dart';
import '../data/models/category_model.dart';

class CategoryRepository extends ChangeNotifier {
  final CategoryService service;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  CategoryRepository(this.service);

  Future<void> fetchCategories() async {
    _categories = await service.getCategories();
    notifyListeners(); // يخطر UI عند التغيير
  }
}
