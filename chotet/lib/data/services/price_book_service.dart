import '../api_client.dart';
import '../dtos/price_book_dto.dart';

class PriceBookService {
  final ApiClient _apiClient;

  PriceBookService(this._apiClient);

  Future<List<PriceBookDto>> getAllPrices() async {
    try {
      final response = await _apiClient.dio.get('/v1/price-book');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PriceBookDto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch prices');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PriceBookDto>> searchPrices(String itemName) async {
    try {
      final response = await _apiClient.dio.get(
        '/v1/price-book/search',
        queryParameters: {'itemName': itemName},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PriceBookDto.fromJson(json)).toList();
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PriceBookDto> addPriceLog(PriceBookDto dto) async {
    try {
      final response = await _apiClient.dio.post(
        '/v1/price-book',
        data: dto.toJson(),
      );
      if (response.statusCode == 201) {
        return PriceBookDto.fromJson(response.data);
      } else {
        throw Exception('Failed to add price log');
      }
    } catch (e) {
      rethrow;
    }
  }
}
