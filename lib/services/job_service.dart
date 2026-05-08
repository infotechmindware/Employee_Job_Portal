import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class JobService {
  static const String baseUrl = 'https://www.mindwareinfotech.com/api/v1';
  static const String searchBaseUrl = 'https://www.mindwareinfotech.com/api';

  /// Search job titles exactly like web version
  static Future<List<String>> getJobTitleSuggestions(String query) async {
    if (query.length < 2) return [];

    try {
      final url = Uri.parse('$searchBaseUrl/job-titles/search?q=${Uri.encodeComponent(query)}&limit=8');
      
      final auth = AuthService();
      final token = await auth.getToken();

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic result = json.decode(response.body);
        List suggestionsData = [];

        if (result is List) {
          suggestionsData = result;
        } else if (result is Map) {
          suggestionsData = result['suggestions'] ?? result['data'] ?? result['results'] ?? [];
        }

        return suggestionsData
            .map((item) {
              if (item is Map) return item['title']?.toString() ?? item['name']?.toString() ?? '';
              return item.toString();
            })
            .where((s) => s.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('❌ Job Search Error: $e');
    }
    return [];
  }

  /// Suggest skills based on job title and category
  static Future<List<String>> getSkillSuggestions({
    required String query,
    required String title,
    String category = 'IT / Software',
  }) async {
    try {
      final url = Uri.parse(
        '$searchBaseUrl/skills/suggest?q=$query&title=${Uri.encodeComponent(title)}&category=${Uri.encodeComponent(category)}&limit=8'
      );
      
      final auth = AuthService();
      final token = await auth.getToken();

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic result = json.decode(response.body);
        List suggestionsData = [];

        if (result is List) {
          suggestionsData = result;
        } else if (result is Map) {
          suggestionsData = result['suggestions'] ?? result['data'] ?? result['results'] ?? [];
        }

        return suggestionsData
            .map((item) {
              if (item is Map) return item['name']?.toString() ?? item['title']?.toString() ?? '';
              return item.toString();
            })
            .where((s) => s.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('❌ Skill Suggestion Error: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> createJob(Map<String, dynamic> jobData) async {
    try {
      final url = Uri.parse('$baseUrl/employer/jobs');
      final auth = AuthService();
      final token = await auth.getToken();
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(jobData),
      ).timeout(const Duration(seconds: 15));

      final result = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': result['message'] ?? 'Job posted successfully'};
      } else {
        return {'success': false, 'message': result['message'] ?? 'Failed to post job'};
      }
    } catch (e) {
      print('❌ Create Job Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateJob(int jobId, Map<String, dynamic> jobData) async {
    try {
      final url = Uri.parse('$baseUrl/employer/jobs/$jobId');
      final auth = AuthService();
      final token = await auth.getToken();
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode(jobData),
      ).timeout(const Duration(seconds: 15));

      final result = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': result['message'] ?? 'Job updated successfully'};
      } else {
        return {'success': false, 'message': result['message'] ?? 'Failed to update job'};
      }
    } catch (e) {
      print('❌ Update Job Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<List<dynamic>> getEmployerJobs() async {
    try {
      final url = Uri.parse('$baseUrl/employer/jobs?per_page=1000');
      final auth = AuthService();
      final token = await auth.getToken();

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result is List) return result;
        if (result is Map) {
          final data = result['data'];
          if (data is Map) {
            // Check for nested keys like 'jobs' or 'data' again
            return data['jobs'] ?? data['data'] ?? [];
          }
          if (data is List) return data;
          return result['jobs'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print('❌ Get Jobs Error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getEmployerApplications() async {
    try {
      final url = Uri.parse('$baseUrl/employer/applications?per_page=1000');
      final auth = AuthService();
      final token = await auth.getToken();

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result is List) return result;
        if (result is Map) {
          final data = result['data'];
          if (data is Map) {
            // Check for nested keys like 'applications'
            return data['applications'] ?? data['data'] ?? [];
          }
          if (data is List) return data;
          return result['applications'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print('❌ Get Applications Error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getJobDetails(int jobId) async {
    try {
      final url = Uri.parse('$baseUrl/employer/jobs/$jobId');
      final auth = AuthService();
      final token = await auth.getToken();

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['data'] ?? result;
      }
    } catch (e) {
      print('❌ Get Job Details Error: $e');
    }
    return null;
  }

  static Future<bool> publishJob(int jobId) async {
    try {
      final url = Uri.parse('$baseUrl/employer/jobs/$jobId/publish');
      final auth = AuthService();
      final token = await auth.getToken();

      final response = await http.patch(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Publish Job Error: $e');
      return false;
    }
  }

  static Future<bool> unpublishJob(int jobId) async {
    try {
      final url = Uri.parse('$baseUrl/employer/jobs/$jobId/unpublish');
      final auth = AuthService();
      final token = await auth.getToken();

      final response = await http.patch(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Unpublish Job Error: $e');
      return false;
    }
  }
}
