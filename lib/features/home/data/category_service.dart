import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/category_model.dart';

class CategoryService {
  final Dio dio;

  CategoryService(this.dio);

  Future<List<CategoryModel>> getCategories() async {
    final response = await dio.get(ApiEndpoints.categories);

    final data = response.data;

    // تعديل هنا: الأقسام موجودة تحت المفتاح 'data' حسب الباك اند
    return (data['data'] as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
  }
}
