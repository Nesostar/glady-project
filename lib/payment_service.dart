import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config/api_config.dart';

class PaymentService {
  // Save transaction data to Firestore
  static Future<void> saveTransaction(Map<String, dynamic> transactionData) async {
    try {
      await FirebaseFirestore.instance.collection('transactions').add(transactionData);
      print('✅ Transaction saved successfully.');
    } catch (e) {
      print('❌ Failed to save transaction: $e');
    }
  }

  // Process mobile money payment
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

      print('🚀 Making POST request to: ${ApiConfig.zenoPayBaseUrl}');
      print('📦 Request body: ${jsonEncode(requestBody)}');
      print('📋 Headers: ${ApiConfig.headers}');

      final response = await http.post(
        Uri.parse(ApiConfig.zenoPayBaseUrl),
        headers: ApiConfig.headers,
        body: jsonEncode(requestBody),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Save transaction with initial status = pending
        await saveTransaction({
          'transaction_id': responseData['transaction_id'] ?? '',
          'order_id': orderId,
          'buyer_name': buyerName,
          'buyer_email': buyerEmail,
          'buyer_phone': buyerPhone,
          'amount': amount,
          'status': 'PENDING',
          'timestamp': FieldValue.serverTimestamp(),
          'response': responseData,
        });

        return {
          'success': true,
          'data': responseData,
          'message': 'Payment request sent successfully',
        };
      } else {
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

  // Check payment status and update Firestore record
  static Future<Map<String, dynamic>> checkPaymentStatus({
    required String transactionId,
    required String orderId,
    required String buyerName,
    required String buyerEmail,
    required String buyerPhone,
    required double amount,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.zenoPayBaseUrl}/status/$transactionId'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Update transaction record with new status
        await saveTransaction({
          'transaction_id': responseData['transaction_id'] ?? transactionId,
          'order_id': orderId,
          'buyer_name': buyerName,
          'buyer_email': buyerEmail,
          'buyer_phone': buyerPhone,
          'amount': amount,
          'status': responseData['status'] ?? 'PENDING',
          'timestamp': FieldValue.serverTimestamp(),
          'response': responseData,
        });

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
      return {
        'success': true,
        'status': 'PENDING',
        'message': 'Status check temporarily unavailable',
      };
    }
  }

  // Generate unique order ID
  static String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORDER_${timestamp}_${(timestamp % 10000).toString().padLeft(4, '0')}';
  }

  // Validate Tanzanian phone number format
  static bool isValidTanzanianPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final patterns = [
      RegExp(r'^\+255[67]\d{8}$'),
      RegExp(r'^0[67]\d{8}$'),
      RegExp(r'^255[67]\d{8}$'),
    ];
    return patterns.any((pattern) => pattern.hasMatch(cleanPhone));
  }

  // Format phone number to 255XXXXXXXXX
  static String formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.startsWith('+255')) {
      return cleanPhone.substring(1);
    } else if (cleanPhone.startsWith('255')) {
      return cleanPhone;
    } else if (cleanPhone.startsWith('0')) {
      return '255${cleanPhone.substring(1)}';
    } else if (cleanPhone.length == 9 && cleanPhone.startsWith(RegExp(r'[67]'))) {
      return '255$cleanPhone';
    }
    return cleanPhone;
  }

  // Test payment method
  static Future<Map<String, dynamic>> testPayment() async {
    return await processMobileMoneyPayment(
      orderId: generateOrderId(),
      buyerEmail: 'test@example.com',
      buyerName: 'Test User',
      buyerPhone: '0675177678',
      amount: 1000.0,
    );
  }

  // Legacy initiate payment (for backward compatibility)
  static Future<String> initiatePayment({
    required double amount,
    required String method,
    required String customerPhone,
  }) async {
    final orderId = generateOrderId();

    final result = await processMobileMoneyPayment(
      orderId: orderId,
      buyerEmail: 'customer@example.com',
      buyerName: 'Customer',
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
