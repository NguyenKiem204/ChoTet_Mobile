import 'package:dio/dio.dart';
import '../api_client.dart';
import '../dtos/auth_dtos.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      
      // The backend returns ApiResponse<AuthResponse>
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return AuthResponse.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      }
      throw Exception('Network error or server is down');
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return AuthResponse.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Registration failed');
      }
      throw Exception('Network error or server is down');
    } catch (e) {
      // In case it's an Exception we threw above
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<UserInfo> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return UserInfo.fromJson(data);
      } else {
        throw Exception('Failed to get user info');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserInfo> updateProfile({
    String? firstName,
    String? lastName,
    String? nickname,
    String? avatarUrl,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/users/profile',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'nickname': nickname,
          'avatarUrl': avatarUrl,
        }..removeWhere((k, v) => v == null),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return UserInfo.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiClient.dio.post(
        '/users/profile/avatar',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['data']; // The URL string
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload avatar');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> googleLogin(String idToken) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/oauth2/google',
        data: {'token': idToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return AuthResponse.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Google login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> facebookLogin(String accessToken) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/oauth2/facebook',
        data: {'token': accessToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return AuthResponse.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Facebook login failed');
      }
    } catch (e) {
      rethrow;
    }
  }
}
