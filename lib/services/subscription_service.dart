import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SubscriptionService {
  static const String baseUrl = 'https://www.mindwareinfotech.com/api/v1';

  static Future<Map<String, dynamic>> createOrder({
    required int planId,
    required String gateway,
    String? billingCycle,
    String paymentMethod = 'card',
  }) async {
    try {
      final url = '$baseUrl/payments/initiate';
      print('🚀 [Razorpay] Calling Working API: $url');
      
      final auth = AuthService();
      final token = await auth.getToken();
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({
          'plan_id': planId,
          'gateway': gateway,
          'billing_cycle': billingCycle ?? 'monthly',
          'payment_method': paymentMethod,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📦 [Razorpay] API Status: ${response.statusCode}');
      print('📦 [Razorpay] API Response Body: ${response.body}');

      final bodyData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle direct response or wrapped in 'data'
        final data = bodyData['data'] ?? bodyData;
        
        if (bodyData['status'] == false || bodyData['success'] == false || bodyData['error'] != null) {
          return {
            'success': false,
            'message': bodyData['message'] ?? bodyData['error'] ?? 'Failed to initiate payment',
          };
        }

        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': bodyData['message'] ?? bodyData['error'] ?? 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ [Razorpay] API Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String razorpayPaymentId,
    required String signature,
    required String subscriptionId,
  }) async {
    try {
      final url = '$baseUrl/payments/verify';
      print('🚀 [Razorpay] Verifying at: $url');
      
      final auth = AuthService();
      final token = await auth.getToken();
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({
          'order_id': orderId,
          'payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': signature,
          'subscription_id': subscriptionId,
          'signature': signature,
        }),
      ).timeout(const Duration(seconds: 15));

      final bodyData = jsonDecode(response.body);
      print('📦 [Razorpay] Verify Response: ${response.body}');

      if (response.statusCode == 200 || bodyData['success'] == true) {
        return {
          'success': true,
          'data': bodyData['data'] ?? bodyData,
        };
      } else {
        return {
          'success': false,
          'message': bodyData['message'] ?? bodyData['error'] ?? 'Verification failed',
        };
      }
    } catch (e) {
      print('❌ [Razorpay] Verify Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPlans() async {
    try {
      final url = '$baseUrl/employer/subscription/plans';
      final auth = AuthService();
      final token = await auth.getToken();
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? data,
        };
      }
      return {'success': false, 'message': 'Failed to fetch plans'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getBillingOverview() async {
    try {
      final url = '$baseUrl/employer/billing/overview';
      final auth = AuthService();
      final token = await auth.getToken();
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 15));

      final bodyData = jsonDecode(response.body);
      
      if (response.statusCode == 200 || bodyData['success'] == true) {
        // Requirement: Ensure API response parsing uses: final data = response['data'];
        final data = bodyData['data'];
        
        if (data == null) {
          return {
            'success': false,
            'message': 'No data received from server'
          };
        }

        return {
          'success': true,
          'data': data, // Keep raw data for flexibility if needed, but UI will use model
        };
      }
      return {
        'success': false, 
        'message': bodyData['message'] ?? 'Failed to fetch billing overview'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getTransactions({
    String? from,
    String? to,
    String? status,
    String? method,
    String? product,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final auth = AuthService();
      final token = await auth.getToken();
      
      var url = '$baseUrl/employer/billing/transactions?page=$page&per_page=$perPage';
      if (from != null) url += '&from=$from';
      if (to != null) url += '&to=$to';
      if (status != null && status != 'All' && status != 'ALL') url += '&status=${status.toLowerCase()}';
      if (method != null && method != 'ALL') url += '&method=${method.toLowerCase()}';
      if (product != null && product != 'ALL') url += '&product=${product.toLowerCase()}';

      print('🚀 [Transactions] Fetching: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 15));

      final bodyData = jsonDecode(response.body);
      
      if (response.statusCode == 200 || bodyData['success'] == true) {
        return {
          'success': true,
          'data': bodyData['data'],
        };
      }
      return {
        'success': false, 
        'message': bodyData['message'] ?? 'Failed to fetch transactions'
      };
    } catch (e) {
      print('❌ [Transactions] Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
