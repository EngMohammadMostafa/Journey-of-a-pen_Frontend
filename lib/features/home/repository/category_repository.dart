
import '../data/category_service.dart';
import '../data/models/category_model.dart';

class CategoryRepository {
  final CategoryService service;

  CategoryRepository(this.service);

  Future<List<CategoryModel>> fetchCategories() {
    return service.getCategories();
  }
}
