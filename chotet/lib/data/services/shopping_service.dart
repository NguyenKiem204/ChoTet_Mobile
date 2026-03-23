import 'package:dio/dio.dart';
import '../api_client.dart';
import '../dtos/shopping_dtos.dart';

class ShoppingService {
  final ApiClient _apiClient;

  ShoppingService(this._apiClient);

  // --- Shopping List Operations ---

  Future<List<ShoppingListDto>> getShoppingLists() async {
    try {
      final response = await _apiClient.dio.get('/v1/shopping-lists');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ShoppingListDto.fromJson(json)).toList();
      }
      throw Exception('Failed to load shopping lists');
    } catch (e) {
      rethrow;
    }
  }

  Future<ShoppingListDto> getShoppingList(int id) async {
    try {
      final response = await _apiClient.dio.get('/v1/shopping-lists/$id');
      if (response.statusCode == 200) {
        return ShoppingListDto.fromJson(response.data);
      }
      throw Exception('Failed to load shopping list');
    } catch (e) {
      rethrow;
    }
  }

  Future<ShoppingListDto> createShoppingList(ShoppingListDto dto) async {
    try {
      final response = await _apiClient.dio.post(
        '/v1/shopping-lists',
        data: dto.toJson(),
      );
      if (response.statusCode == 201) {
        return ShoppingListDto.fromJson(response.data);
      }
      throw Exception('Failed to create shopping list');
    } catch (e) {
      rethrow;
    }
  }

  Future<ShoppingListDto> updateShoppingList(int id, ShoppingListDto dto) async {
    try {
      final response = await _apiClient.dio.put(
        '/v1/shopping-lists/$id',
        data: dto.toJson(),
      );
      if (response.statusCode == 200) {
        return ShoppingListDto.fromJson(response.data);
      }
      throw Exception('Failed to update shopping list');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteShoppingList(int id) async {
    try {
      await _apiClient.dio.delete('/v1/shopping-lists/$id');
    } catch (e) {
      rethrow;
    }
  }

  // --- Shopping Item Operations ---

  Future<ShoppingItemDto> addItemToList(int listId, ShoppingItemDto dto) async {
    try {
      final response = await _apiClient.dio.post(
        '/v1/shopping-lists/$listId/items',
        data: dto.toJson(),
      );
      if (response.statusCode == 201) {
        return ShoppingItemDto.fromJson(response.data);
      }
      throw Exception('Failed to add item');
    } catch (e) {
      rethrow;
    }
  }

  Future<ShoppingItemDto> updateItem(int listId, int itemId, ShoppingItemDto dto) async {
    try {
      final response = await _apiClient.dio.put(
        '/v1/shopping-lists/$listId/items/$itemId',
        data: dto.toJson(),
      );
      if (response.statusCode == 200) {
        return ShoppingItemDto.fromJson(response.data);
      }
      throw Exception('Failed to update item');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteItem(int listId, int itemId) async {
    try {
      await _apiClient.dio.delete('/v1/shopping-lists/$listId/items/$itemId');
    } catch (e) {
      rethrow;
    }
  }

  // --- AI Receipt Scanner ---

  Future<ScanResponseDto> scanReceipt(int listId, String filePath) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiClient.dio.post(
        '/v1/receipt-scanner/scan/$listId',
        data: formData,
        options: Options(receiveTimeout: const Duration(seconds: 120)),
      );

      if (response.statusCode == 200) {
        return ScanResponseDto.fromJson(response.data['data']);
      }
      throw Exception('Failed to scan receipt');
    } catch (e) {
      rethrow;
    }
  }

  Future<ShoppingListDto> shareList(int listId, String usernameOrEmail) async {
    try {
      final response = await _apiClient.dio.post(
        '/v1/shopping-lists/$listId/share',
        data: {'usernameOrEmail': usernameOrEmail},
      );
      if (response.statusCode == 200) {
        return ShoppingListDto.fromJson(response.data);
      }
      throw Exception('Failed to share list');
    } catch (e) {
      rethrow;
    }
  }

  Future<ShoppingListDto> unshareList(int listId, int userId) async {
    try {
      final response = await _apiClient.dio.delete(
        '/v1/shopping-lists/$listId/share/$userId',
      );
      if (response.statusCode == 200) {
        return ShoppingListDto.fromJson(response.data);
      }
      throw Exception('Failed to unshare list');
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadShoppingImage(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiClient.dio.post(
        '/v1/shopping-lists/upload-image',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as String;
      }
      throw Exception('Failed to upload image');
    } catch (e) {
      rethrow;
    }
  }

}
