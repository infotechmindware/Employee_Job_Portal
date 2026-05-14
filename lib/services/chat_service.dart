import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ChatService {
  static const String baseUrl = 'https://www.mindwareinfotech.com/api/v1';

  static Future<Map<String, dynamic>> getConversations() async {
    try {
      final url = '$baseUrl/conversations';
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

      final bodyData = jsonDecode(response.body);
      if (response.statusCode == 200 || bodyData['success'] == true || bodyData['status'] == true) {
        return {
          'success': true,
          'data': bodyData['data'] ?? bodyData,
        };
      }
      return {
        'success': false, 
        'message': bodyData['message'] ?? 'Failed to fetch conversations'
      };
    } catch (e) {
      print('❌ [ChatService] getConversations Error: $e');
      return {'success': false, 'message': e is http.ClientException ? 'Connection error' : 'Timeout error'};
    }
  }

  static Future<Map<String, dynamic>> getMessages(String conversationId) async {
    try {
      final url = '$baseUrl/conversations/$conversationId/messages';
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

      print("FULL RESPONSE (getMessages) => ${response.body}");
      final bodyData = jsonDecode(response.body);
      if (response.statusCode == 200 || bodyData['success'] == true || bodyData['status'] == true) {
        return {
          'success': true,
          'data': bodyData['data'] ?? bodyData,
        };
      }
      return {
        'success': false, 
        'message': bodyData['message'] ?? 'Failed to fetch messages'
      };
    } catch (e) {
      print('❌ [ChatService] getMessages Error: $e');
      return {'success': false, 'message': 'Connection/Timeout error'};
    }
  }

  static Future<Map<String, dynamic>> sendMessage(String conversationId, String message) async {
    try {
      final url = '$baseUrl/conversations/$conversationId/messages';
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
          'content': message,
        }),
      ).timeout(const Duration(seconds: 10));

      final bodyData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201 || bodyData['success'] == true || bodyData['status'] == true) {
        return {
          'success': true,
          'data': bodyData['data'] ?? bodyData,
        };
      }
      return {
        'success': false, 
        'message': bodyData['message'] ?? 'Failed to send message'
      };
    } catch (e) {
      print('❌ [ChatService] sendMessage Error: $e');
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> sendImageMessage(String conversationId, String imagePath) async {
    try {
      final url = '$baseUrl/conversations/$conversationId/messages';
      final auth = AuthService();
      final token = await auth.getToken();
      
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'X-Requested-With': 'XMLHttpRequest',
      });

      // Try 'image' instead of 'attachment' as 'attachment' resulted in empty bubbles
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      // Backend requires non-empty content even for images
      request.fields['content'] = 'Sent an image'; 

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      print("--- IMAGE UPLOAD DEBUG ---");
      print("STATUS CODE => ${response.statusCode}");
      print("RESPONSE BODY => ${response.body}");
      print("--------------------------");

      final bodyData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201 || bodyData['success'] == true || bodyData['status'] == true) {
        return {
          'success': true,
          'data': bodyData['data'] ?? bodyData,
        };
      }
      return {
        'success': false, 
        'message': bodyData['message'] ?? 'Failed to upload image'
      };
    } catch (e) {
      print('❌ IMAGE UPLOAD ERROR => $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
