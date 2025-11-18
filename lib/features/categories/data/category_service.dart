import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import 'models/category_model.dart';

class CategoryService {
  final Dio dio;

  CategoryService(this.dio);

  Future<List<CategoryModel>> getCategories() async {
    final response = await dio.get(ApiEndpoints.categories);

    // التأكد من أن response.data هو Map
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;

    if (data['success'] == true) {
      return (data['data'] as List<dynamic>)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } else {
      // في حالة فشل الطلب، يمكن إعادة قائمة فارغة أو رمي Exception
      return [];
    }
  }
}
