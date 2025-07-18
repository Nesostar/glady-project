import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ 10.0.2.2 is used to access localhost from Android emulator.
  // ✅ Use 'localhost' if testing on browser or iOS
  final String baseUrl = 'http://192.168.43.243:3000';

  /// Sends form data to your backend: POST /submit-form
  Future<http.Response> initiatePayment(Map<String, dynamic> data) async {
  final response = await http.post(
    Uri.parse('http://192.168.43.243:3000/initiate-payment'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  print('📡 Sent to backend: ${response.statusCode}');
  print('📡 Response: ${response.body}');

  return response;
}

  /// Gets status from backend: GET / (or /status if you define it)
  Future<http.Response> getStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/')); // or /status if defined
    print('🔍 Status Code: ${response.statusCode}');
    print('📝 Response Body: ${response.body}');
    return response;
  }
}
