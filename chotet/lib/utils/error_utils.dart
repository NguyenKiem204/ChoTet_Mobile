import 'package:dio/dio.dart';

class ErrorUtils {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data is Map) {
        final data = error.response!.data;
        if (data['message'] != null) {
          return data['message'].toString();
        }
      }
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Kết nối quá hạn (Connection timeout)';
        case DioExceptionType.receiveTimeout:
          return 'Phản hồi quá chậm (Receive timeout)';
        case DioExceptionType.sendTimeout:
          return 'Gửi dữ liệu quá chậm (Send timeout)';
        case DioExceptionType.badResponse:
          return 'Lỗi từ máy chủ: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Yêu cầu đã bị hủy';
        case DioExceptionType.connectionError:
          return 'Không thể kết nối đến máy chủ. Kiểm tra mạng hoặc địa chỉ IP.';
        default:
          return 'Lỗi mạng không xác định: ${error.message}';
      }
    }
    return error.toString();
  }
}
