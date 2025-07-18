import 'dart:convert';
import 'api_service.dart'; // Make sure the path is correct

class PaymentService {
  static Future<String> initiatePayment({
    required double amount,
    required String method,
    required String customerPhone,
  }) async {
    final api = ApiService();

    final response = await api.initiatePayment({
      'amount': amount.toString(),
      'currency': 'TZS',
      'phoneNumber': customerPhone,
      'paymentMethod': method,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['transaction_id'] ?? 'Transaction initiated';
    } else {
      throw Exception('Payment failed: ${response.body}');
    }
  }
}
