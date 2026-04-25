import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _api.setTokens(
      response.data['access_token'],
      response.data['refresh_token'],
    );
    return response.data;
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await _api.dio.post('/auth/register', data: {
      'email': email,
      'password': password,
    });
    await _api.setTokens(
      response.data['access_token'],
      response.data['refresh_token'],
    );
    return response.data;
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } catch (_) {}
    await _api.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    final token = await _api.getAccessToken();
    return token != null;
  }
}
