import 'dart:convert';
import 'package:http/http.dart' as http;

class EmployerAuthService {
  static const String baseUrl = 'https://mindwareinfotech.com/api/v1';

  /// 1. Send Email OTP
  Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-email-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({
          "email": email,
          "purpose": "register_employer",
          "role": "employer",
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// 2. Register Employer (Email + Password)
  Future<Map<String, dynamic>> registerEmployer({
    required String companyName,
    required String email,
    required String phone,
    required String fullName,
    required String registerAs,
    required String industry,
    required String companyType,
    required String companySize,
    required String gstin,
    required String website,
    required String pincode,
    required String password,
    required String confirmPassword,
    required String emailOtp,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "company_name": companyName,
        "email": email,
        "phone": phone,
        "full_name": fullName,
        "register_as": registerAs,
        "industry": industry,
        "service_category": industry,
        "service_categories": [industry],
        "company_type": companyType,
        "company_size": companySize,
        "gstin": gstin,
        "website": website,
        "pincode": pincode,
        "address": {
          "street": "",
          "city": "",
          "state": "",
          "country": "India",
          "postal_code": pincode,
        },
        "password": password,
        "confirm_password": confirmPassword,
        "email_otp": emailOtp,
        "role": "employer",
        "profession_type": "employer",
      };

      final response = await http.post(
        Uri.parse('$baseUrl/register-employer'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// 3. Send Phone OTP
  Future<Map<String, dynamic>> sendPhoneOtp({
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-phone-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({
          "phone": phone,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// 4. Register Employer with Phone OTP
  Future<Map<String, dynamic>> registerEmployerPhone({
    required String phone,
    required String otp,
    required String companyName,
    required String email,
    required String password,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "phone": phone,
        "otp": otp,
        "company_name": companyName,
        "email": email,
        "password": password,
        "role": "employer",
        "profession_type": "employer",
        "service_category": "IT/Software",
        "service_categories": ["IT/Software"],
      };

      final response = await http.post(
        Uri.parse('$baseUrl/register-employer-phone'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Helper method to safely parse the HTTP response and handle codes
  Map<String, dynamic> _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;
    
    Map<String, dynamic> responseData = {};
    try {
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          responseData = Map<String, dynamic>.from(decoded);
        } else {
          responseData = {'data': decoded};
        }
      }
    } catch (_) {
      // Body isn't JSON
    }

    final String message = responseData['message'] ?? responseData['error'] ?? 'An error occurred';

    if (statusCode == 200 || statusCode == 201) {
      return {
        'success': true,
        'message': message,
        'data': responseData,
      };
    } else if (statusCode == 400 || statusCode == 401 || statusCode == 422) {
      return {
        'success': false,
        'message': message,
        'data': responseData,
      };
    } else {
      return {
        'success': false,
        'message': 'Server error ($statusCode): $message',
        'data': responseData,
      };
    }
  }
}
