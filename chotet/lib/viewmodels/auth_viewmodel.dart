import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/api_client.dart';
import '../data/dtos/auth_dtos.dart';
import '../data/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final ApiClient _apiClient;
  final _secureStorage = const FlutterSecureStorage();
  
  UserInfo? _user;
  bool _isLoading = false;
  String? _error;

  UserInfo? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthViewModel(this._authService, this._apiClient) {
    _initApiClient();
    _checkSession();
  }

  void _initApiClient() {
    _apiClient.getRefreshToken = () async {
      return await _secureStorage.read(key: 'refreshToken');
    };
    
    _apiClient.onTokenRefreshed = (accessToken, refreshToken) async {
      _apiClient.setAccessToken(accessToken);
      if (refreshToken != null) {
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);
      }
    };
    
    _apiClient.onLogout = () {
      logout();
    };
  }

  Future<void> _checkSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final refreshToken = await _secureStorage.read(key: 'refreshToken');
      if (refreshToken != null) {
        _user = await _authService.getCurrentUser();
      }
    } catch (e) {
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('saved_username');
    final password = await _secureStorage.read(key: 'saved_password');
    return {
      'username': username,
      'password': password,
    };
  }

  Future<void> _saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_username', username);
    await _secureStorage.write(key: 'saved_password', value: password);
  }

  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_username');
    await _secureStorage.delete(key: 'saved_password');
  }

  Future<bool> login(String username, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequest(username: username, password: password),
      );
      
      _user = response.user;
      
      // Store accessToken in memory (via ApiClient)
      _apiClient.setAccessToken(response.accessToken);
      
      // Store refreshToken in secure storage
      if (response.refreshToken != null) {
        await _secureStorage.write(key: 'refreshToken', value: response.refreshToken);
      }
      
      if (rememberMe) {
        await _saveCredentials(username, password);
      } else {
        await _clearCredentials();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(RegisterRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(request);
      
      _user = response.user;
      _apiClient.setAccessToken(response.accessToken);
      
      if (response.refreshToken != null) {
        await _secureStorage.write(key: 'refreshToken', value: response.refreshToken);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'refreshToken');
    _apiClient.setAccessToken(null);
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? nickname,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        nickname: nickname,
        avatarUrl: avatarUrl,
      );
      _user = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<String?> uploadAvatar(String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = await _authService.uploadAvatar(filePath);
      _isLoading = false;
      notifyListeners();
      return url;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> googleLogin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception("Failed to get ID Token from Google");
      }

      final response = await _authService.googleLogin(idToken);
      await _handleAuthSuccess(response);
      
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> facebookLogin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        if (accessToken == null) {
          throw Exception("Failed to get Access Token from Facebook");
        }

        final response = await _authService.facebookLogin(accessToken.token);
        await _handleAuthSuccess(response);
        return true;
      } else if (result.status == LoginStatus.cancelled) {
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        throw Exception(result.message ?? "Facebook login failed");
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _handleAuthSuccess(AuthResponse response) async {
    _user = response.user;
    _apiClient.setAccessToken(response.accessToken);
    if (response.refreshToken != null) {
      await _secureStorage.write(key: 'refreshToken', value: response.refreshToken);
    }
    _isLoading = false;
    notifyListeners();
  }
}
