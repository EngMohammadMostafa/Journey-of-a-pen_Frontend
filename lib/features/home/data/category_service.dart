import '../../../../../core/api/api_service.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/category_model.dart';

class CategoryService {
  final ApiService api;

  CategoryService(this.api);

  Future<List<CategoryModel>> getCategories() async {
    final response = await api.get(ApiEndpoints.categories);
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;

    if (data['success'] == true) {
      final list = data['categories'] ?? data['data'] ?? [];
      return (list as List).map((e) => CategoryModel.fromJson(e)).toList();
    }
    return [];
  }
}
