import 'package:book_worm_haven/core/api/api_service.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/category_model.dart';

class CategoryService {
  final ApiService api;

  CategoryService(this.api);

  Future<List<CategoryModel>> getCategories() async {
    final response = await api.get(ApiEndpoints.categories);

    final data = response.data;

    return (data['data'] as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
  }
}
