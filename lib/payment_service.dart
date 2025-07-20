import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config/api_config.dart';

class PaymentService {
  // ZenoPay Mobile Money Payment Request Model
  static Future<Map<String, dynamic>> processMobileMoneyPayment({
    required String orderId,
    required String buyerEmail,
    required String buyerName,
    required String buyerPhone,
    required double amount,
  }) async {
    try {
      final requestBody = {
        'order_id': orderId,
        'buyer_email': buyerEmail,
        'buyer_name': buyerName,
        'buyer_phone': buyerPhone,
        'amount': amount.toInt(),
      };

      // Debug logging
      print('🚀 Making POST request to: ${ApiConfig.zenoPayBaseUrl}');
      print('📦 Request body: ${jsonEncode(requestBody)}');
      print('📋 Headers: ${ApiConfig.headers}');
      print('📱 Phone number being sent: $buyerPhone');

      final response = await http.post(
        Uri.parse(ApiConfig.zenoPayBaseUrl),
        headers: ApiConfig.headers,
        body: jsonEncode(requestBody),
      );

      // Debug response
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Payment request sent successfully',
        };
      } else {
        print('❌ Payment failed with status: ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData,
          'message': 'Payment request failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Payment error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Network error occurred',
      };
    }
  }

  // Generate unique order ID
  static String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORDER_${timestamp}_${(timestamp % 10000).toString().padLeft(4, '0')}';
  }

  // Validate phone number for Tanzania mobile money
  static bool isValidTanzanianPhone(String phone) {
    // Remove any spaces, dashes, and special characters except +
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Check for valid Tanzanian mobile patterns
    // +255 followed by 9 digits or 0 followed by 9 digits
    final patterns = [
      RegExp(r'^\+255[67]\d{8}$'), // +255 6xxxxxxxx or +255 7xxxxxxxx
      RegExp(r'^0[67]\d{8}$'), // 06xxxxxxxx or 07xxxxxxxx
      RegExp(r'^255[67]\d{8}$'), // 255 6xxxxxxxx or 255 7xxxxxxxx
    ];

    return patterns.any((pattern) => pattern.hasMatch(cleanPhone));
  }

  // Format phone number to required format
  static String formatPhoneNumber(String phone) {
    // Remove any spaces, dashes, and special characters except +
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Convert to 255XXXXXXXXX format (what most APIs expect)
    if (cleanPhone.startsWith('+255')) {
      return cleanPhone.substring(1); // Remove +, keep 255XXXXXXXXX
    } else if (cleanPhone.startsWith('255')) {
      return cleanPhone; // Already in correct format: 255XXXXXXXXX
    } else if (cleanPhone.startsWith('0')) {
      return '255${cleanPhone.substring(1)}'; // Convert 0XXXXXXXXX to 255XXXXXXXXX
    }

    // If it's already in the right format (no prefix), assume it needs 255
    if (cleanPhone.length == 9 && cleanPhone.startsWith(RegExp(r'[67]'))) {
      return '255$cleanPhone';
    }

    return cleanPhone;
  }

  // Test different phone number formats
  static void testPhoneFormats() {
    final testNumbers = [
      '0712345678',
      '+255712345678',
      '255712345678',
      '712345678',
      '0675177678',
      '+255675177678',
    ];

    print('📱 Testing phone number formats:');
    for (final number in testNumbers) {
      final formatted = formatPhoneNumber(number);
      final isValid = isValidTanzanianPhone(number);
      print('Input: $number → Formatted: $formatted → Valid: $isValid');
    }
  }

  // Test payment method to verify POST requests are working
  static Future<Map<String, dynamic>> testPayment() async {
    return await processMobileMoneyPayment(
      orderId: generateOrderId(),
      buyerEmail: 'test@example.com',
      buyerName: 'Test User',
      buyerPhone: '0675177678',
      amount: 1000.0,
    );
  }

  // Check payment status
  static Future<Map<String, dynamic>> checkPaymentStatus(
      String transactionId) async {
    try {
      // Note: This is a placeholder - you'll need to implement the actual status endpoint
      // For now, we'll simulate checking status
      final response = await http.get(
        Uri.parse('${ApiConfig.zenoPayBaseUrl}/status/$transactionId'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'status': responseData['status'] ?? 'PENDING',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'status': 'FAILED',
          'message': 'Could not check payment status',
        };
      }
    } catch (e) {
      print('💥 Status check error: $e');
      // For now, return PENDING to avoid breaking the flow
      return {
        'success': true,
        'status': 'PENDING',
        'message': 'Status check temporarily unavailable',
      };
    }
  }

  // Legacy method for backward compatibility
  static Future<String> initiatePayment({
    required double amount,
    required String method,
    required String customerPhone,
  }) async {
    final orderId = generateOrderId();

    final result = await processMobileMoneyPayment(
      orderId: orderId,
      buyerEmail: 'customer@example.com', // Default email
      buyerName: 'Customer', // Default name
      buyerPhone: customerPhone,
      amount: amount,
    );

    if (result['success']) {
      return result['data']['transaction_id'] ?? orderId;
    } else {
      throw Exception('Payment failed: ${result['message']}');
    }
  }
}
