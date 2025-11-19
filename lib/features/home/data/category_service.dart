import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/category_model.dart';

class CategoryService {
  final Dio dio;

  CategoryService(this.dio);

  Future<List<CategoryModel>> getCategories() async {
    final response = await dio.get(ApiEndpoints.categories);

    final data = response.data;

    return (data['categories'] as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
  }
}

