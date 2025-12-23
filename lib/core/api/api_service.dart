import 'package:dio/dio.dart';
import 'package:book_worm_haven/core/constants/api_endpoints.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  Dio get dio => _dio;
  String? _authToken;

  final bool isMockMode;

  ApiService._internal({this.isMockMode = false}) {
    BaseOptions options = BaseOptions(
      baseUrl: "http://192.168.0.103:8000/api",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);

    // ====================================================
    //  Interceptor لعرض كل الطلبات والردود والأخطاء
    // ====================================================
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          print("======================================");
          print(" API REQUEST");
          print("➡ URL: ${options.baseUrl}${options.path}");
          print("➡ METHOD: ${options.method}");
          print("➡ HEADERS: ${options.headers}");
          print("➡ QUERY PARAMS: ${options.queryParameters}");
          print("➡ DATA: ${options.data}");
          print("======================================");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("======================================");
          print(" API RESPONSE");
          print(" STATUS: ${response.statusCode}");
          print(" DATA: ${response.data}");
          print("======================================");
          return handler.next(response);
        },
        onError: (error, handler) {
          print("======================================");
          print(" API ERROR");
          print(" MESSAGE: ${error.message}");
          print(" STATUS: ${error.response?.statusCode}");
          print(" DATA: ${error.response?.data}");
          print("======================================");
          return handler.next(error);
        },
      ),
    );
  }

  // تعيين توكن المصادقة لجميع الطلبات
// تعيين توكن المصادقة لجميع الطلبات
  void setAuthToken(String token) {
    _authToken = token;
    print(" Token set successfully: $token");
  }

//  Getter آمن للقراءة فقط
  String? get token => _authToken;


  // دوال عامة
  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) async {
    return await _dio.get(endpoint, queryParameters: params);
  }

  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    return await _dio.post(endpoint, data: data);
  }

  Future<Response> put(String endpoint, {Map<String, dynamic>? data}) async {
    return await _dio.put(endpoint, data: data);
  }

  Future<Response> delete(String endpoint, {Map<String, dynamic>? data}) async {
    return await _dio.delete(endpoint, data: data);
  }

  // تسجيل الدخول
  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    if (isMockMode) {
      print(' Mock Login Enabled → skipping real API call');
      await Future.delayed(const Duration(seconds: 1));
      return {
        "token": "mock_token_12345",
        "user": {"id": 1, "name": "Demo User", "email": credentials['email']},
      };
    }

    try {
      final response = await _dio.post(ApiEndpoints.login, data: credentials);
      final data = Map<String, dynamic>.from(response.data);
      if (data.containsKey('token')) {
        setAuthToken(data['token']); //  حفظ التوكن مباشرة بعد تسجيل الدخول
      }
      return data;
    } on DioException catch (e) {
      print(' Login Exception: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        print('Response status: ${e.response?.statusCode}');
      }
      throw Exception(_handleError(e));
    }
  }

  // التسجيل
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    if (isMockMode) {
      print(' Mock Register Enabled → skipping real API call');
      await Future.delayed(const Duration(seconds: 1));
      return {
        "success": true,
        "message": "Mock registration successful",
        "user": userData,
      };
    }

    try {
      final response = await _dio.post(ApiEndpoints.register, data: userData);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      print(' Register Exception: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        print('Response status: ${e.response?.statusCode}');
      }
      throw Exception(_handleError(e));
    }
  }

  // معالجة الأخطاء
  String _handleError(DioException e) {
    if (e.response != null) {
      return 'Error ${e.response?.statusCode}: ${e.response?.data}';
    } else {
      return 'Connection error: ${e.message}';
    }
  }

  Future<Response> download(String endpoint, {Options? options}) async {
    return await _dio.get(endpoint, options: options);
  }
}
