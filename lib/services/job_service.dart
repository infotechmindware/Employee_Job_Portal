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
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode(jobData),
      ).timeout(const Duration(seconds: 15));

      final result = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': result['data'] ?? result};
      } else {
        return {'success': false, 'message': result['message'] ?? 'Failed to create job'};
      }
    } catch (e) {
      print('❌ Create Job Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateJob(dynamic jobId, Map<String, dynamic> jobData) async {
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
        body: jsonEncode(jobData),
      ).timeout(const Duration(seconds: 15));

      final result = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': result['data'] ?? result};
      } else {
        return {'success': false, 'message': result['message'] ?? 'Failed to update job'};
      }
    } catch (e) {
      print('❌ Update Job Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
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

      print('💼 Get Jobs Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == true || result['success'] == true || result['data'] != null) {
          final data = result['data'] ?? result;
          if (data is Map) {
            return data['jobs'] ?? data['data'] ?? data['results'] ?? [];
          } else if (data is List) {
            return data;
          }
        }
        return result is List ? result : (result['jobs'] ?? result['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('❌ Get Jobs Error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getEmployerApplications({String? jobId, String? status}) async {
    try {
      String urlStr = '$baseUrl/employer/applications?per_page=1000&include=candidate,job';
      if (jobId != null) urlStr += '&job_id=$jobId';
      if (status != null && status != 'All') urlStr += '&status=${status.toLowerCase()}';
      
      final url = Uri.parse(urlStr);
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

      print('📝 Get Applications Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == true || result['success'] == true || result['data'] != null) {
          final data = result['data'] ?? result;
          if (data is Map) {
            // Handle deeply nested or flat structures
            if (data['data'] != null && data['data'] is Map && data['data']['applications'] != null) {
              return data['data']['applications'];
            }
            return data['applications'] ?? data['data'] ?? data['results'] ?? [];
          } else if (data is List) {
            return data;
          }
        }
        return result is List ? result : (result['applications'] ?? result['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('❌ Get Employer Applications Error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getEmployerInterviews({String? status}) async {
    try {
      final auth = AuthService();
      final token = await auth.getToken();
      
      String urlStr = '$baseUrl/employer/interviews?include=candidate,job,application&per_page=1000';
      if (status != null && status.isNotEmpty) {
        urlStr += '&status=$status';
      }
      final url = Uri.parse(urlStr);

      print('🚀 [API] Fetching Interviews from: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 [API] Interviews Status: ${response.statusCode}');
      print('📦 [API] Interviews Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        
        List<dynamic> interviews = [];
        Map<String, dynamic> stats = {};

        if (result is Map) {
          // Robust parsing for Interviews List
          final dynamic data = result['data'];
          if (result['interviews'] is List) {
            interviews = result['interviews'];
          } else if (data is List) {
            interviews = data;
          } else if (data is Map) {
            interviews = data['interviews'] ?? data['data'] ?? [];
          }

          // Robust parsing for Stats
          final dynamic apiStats = result['stats'] ?? (data is Map ? data['stats'] : null);
          if (apiStats is Map) {
            stats = Map<String, dynamic>.from(apiStats);
          } else {
            // Fallback: Check root level for common Laravel stat keys
            stats = {
              'total': result['total'] ?? result['total_interviews'],
              'upcoming': result['upcoming'] ?? result['upcoming_interviews'],
              'today': result['today'] ?? result['today_interviews'],
              'week': result['week'] ?? result['next_7_days'] ?? result['week_interviews'],
              'completed': result['completed'] ?? result['finished_interviews'],
              'missed': result['missed'] ?? result['declined'] ?? result['declined_interviews'],
            };
          }
        } else if (result is List) {
          interviews = result;
        }

        print('✅ [API] Success! Parsed ${interviews.length} interviews. Stats: $stats');
        return {
          'interviews': interviews,
          'stats': stats,
        };
      }
      return {'interviews': [], 'stats': {}};
    } catch (e) {
      print('❌ [API] Get Employer Interviews Error: $e');
      return {'interviews': [], 'stats': {}};
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

  static Future<bool> updateApplicationStatus({
    required dynamic applicationId, 
    required String status,
    dynamic candidateId,
    dynamic jobId,
  }) async {
    print('========== STATUS UPDATE DEBUG ==========');
    print('APPLICATION ID: $applicationId');
    print('CANDIDATE ID: $candidateId');
    print('JOB ID: $jobId');
    print('STATUS BEFORE MAP: $status');

    if (applicationId == null) {
      print('ERROR: APPLICATION ID IS NULL');
      return false;
    }

    try {
      // Map action keys to backend status values if needed
      final Map<String, String> statusMapping = {
        'new': 'applied',
        'interview': 'interviewing',
        'shortlisted': 'shortlisted',
        'contacting': 'contacting',
        'hired': 'hired',
        'rejected': 'rejected',
      };
      
      final String mappedStatus = statusMapping[status.toLowerCase()] ?? status.toLowerCase();
      print('MAPPED STATUS (API STATUS): $mappedStatus');
      
      // Robust multi-endpoint fallback strategy for status updates
      final endpoints = [
        // 1. Action-specific endpoints (High priority)
        if (status == 'shortlist' || status == 'shortlisted') '$baseUrl/employer/applications/$applicationId/shortlist',
        if (status == 'reject' || status == 'rejected') '$baseUrl/employer/applications/$applicationId/reject',
        
        // 2. Dedicated status update endpoint
        '$baseUrl/employer/applications/$applicationId/status',
        
        // 3. Generic application update endpoints
        '$baseUrl/employer/applications/$applicationId',
        '$baseUrl/employer/applications/update-status',
        '$baseUrl/employer/applications/$applicationId/update',
      ];
      
      final auth = AuthService();
      final token = await auth.getToken();

      final body = {
        'status': mappedStatus,
        'application_id': applicationId,
        if (candidateId != null) 'candidate_id': candidateId,
        if (jobId != null) 'job_id': jobId,
        '_method': 'PUT', // For REST compatibility
      };

      for (var urlStr in endpoints) {
        try {
          final url = Uri.parse(urlStr);
          print('📡 [API] Updating Status via: $url');
          
          // For specific action endpoints, we might not need the full body or _method spoofing
          final bool isActionEndpoint = urlStr.endsWith('/shortlist') || 
                                       urlStr.endsWith('/reject') || 
                                       urlStr.endsWith('/status');
          
          final Map<String, dynamic> requestBody = isActionEndpoint 
            ? {'status': mappedStatus} 
            : body;

          print('📦 [API] Payload: $requestBody');

          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              'X-Requested-With': 'XMLHttpRequest',
            },
            body: jsonEncode(requestBody),
          ).timeout(const Duration(seconds: 10));

          print('STATUS CODE: ${response.statusCode}');
          print('RESPONSE BODY: ${response.body}');
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            final result = json.decode(response.body);
            // If body says "Not Found" despite 200, try next fallback
            if (result['error'] == 'Not Found' || result['message'] == 'Not Found') {
              print('⚠️ Endpoint $urlStr returned Not Found in body, trying next...');
              continue;
            }
            return result['success'] == true || result['status'] == true || result['status'] == 'success' || result['message']?.toString().toLowerCase().contains('success') == true;
          } else if (response.statusCode == 404) {
             print('⚠️ Endpoint $urlStr returned 404, trying next...');
             continue;
          }
        } catch (e) {
          print('⚠️ Error with endpoint $urlStr: $e');
        }
      }
      return false;
    } catch (e) {
      print('❌ Update Application Status Error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> scheduleInterview(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/employer/interviews');
      final auth = AuthService();
      final token = await auth.getToken();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      print('🗓️ Schedule Interview Response (${response.statusCode}): ${response.body}');
      
      final result = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': result['data'] ?? result};
      } else {
        return {'success': false, 'message': result['message'] ?? 'Failed to schedule interview'};
      }
    } catch (e) {
      print('❌ Schedule Interview Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>?> getInterviewDetails(dynamic id) async {
    try {
      final auth = AuthService();
      final token = await auth.getToken();
      final url = Uri.parse('$baseUrl/employer/interviews/$id');

      print('🚀 [API] Fetching Interview Details for ID $id from: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 [API] Interview Details Status: ${response.statusCode}');
      print('📦 [API] Interview Details Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result is Map) {
          final data = result['data'] ?? result;
          if (data is Map) {
            return Map<String, dynamic>.from(data);
          }
        }
      }
      return null;
    } catch (e) {
      print('❌ Get Interview Details Error: $e');
      return null;
    }
  }

  static Future<bool> completeInterview(dynamic id) async {
    try {
      final auth = AuthService();
      final token = await auth.getToken();
      final url = Uri.parse('$baseUrl/employer/interviews/$id/complete');

      print('🚀 [API] Completing Interview ID: $id at: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 [API] Complete Interview Status: ${response.statusCode}');
      print('📦 [API] Complete Interview Body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Complete Interview Error: $e');
      return false;
    }
  }

  static Future<bool> cancelInterview(dynamic id) async {
    try {
      final auth = AuthService();
      final token = await auth.getToken();
      final url = Uri.parse('$baseUrl/employer/interviews/$id/cancel');

      print('🚀 [API] Cancelling/Declining Interview ID: $id at: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 [API] Cancel Interview Status: ${response.statusCode}');
      print('📦 [API] Cancel Interview Body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Cancel Interview Error: $e');
      return false;
    }
  }

  static Future<bool> rescheduleInterview(dynamic id, Map<String, dynamic> data) async {
    try {
      final auth = AuthService();
      final token = await auth.getToken();
      final url = Uri.parse('$baseUrl/employer/interviews/$id/reschedule');

      print('🚀 [API] Rescheduling Interview ID: $id at: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      print('📡 [API] Reschedule Interview Status: ${response.statusCode}');
      print('📦 [API] Reschedule Interview Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final resBody = jsonDecode(response.body);
          if (resBody is Map) {
            return resBody['success'] == true || resBody['status'] == true;
          }
        } catch (_) {}
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Reschedule Interview Error: $e');
      return false;
    }
  }
}
