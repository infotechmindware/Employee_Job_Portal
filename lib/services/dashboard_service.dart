import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'job_service.dart';
import 'package:intl/intl.dart';

class DashboardService {
  static const String baseUrl = 'https://www.mindwareinfotech.com/api/v1';
  static const String webUrl = 'https://www.mindwareinfotech.com';

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final auth = AuthService();
      final token = await auth.getToken();

      print('🚀 Fetching Dashboard Data...');

      // Fetch core dashboard data, trends and activities in parallel
      final results = await Future.wait([
        http.get(Uri.parse('$baseUrl/employer/dashboard'), headers: _headers(token)),
        http.get(Uri.parse('$baseUrl/employer/application-trends'), headers: _headers(token)),
        http.get(Uri.parse('$baseUrl/employer/recent-activities'), headers: _headers(token)),
      ]).timeout(const Duration(seconds: 15));

      final dashboardRes = results[0];
      final trendsRes = results[1];
      final activitiesRes = results[2];

      Map<String, dynamic> dashboardData = {};
      if (dashboardRes.statusCode == 200) {
        final dynamic body = json.decode(dashboardRes.body);
        if (body is Map) {
          dashboardData = body['data'] ?? body;
        }
      }

      List<dynamic> trendsData = [];
      if (trendsRes.statusCode == 200) {
        final dynamic body = json.decode(trendsRes.body);
        if (body is List) {
          trendsData = body;
        } else if (body is Map) {
          trendsData = body['data'] ?? body['trends'] ?? body['analytics_data'] ?? [];
        }
      }

      List<dynamic> activitiesData = [];
      if (activitiesRes.statusCode == 200) {
        final dynamic body = json.decode(activitiesRes.body);
        if (body is List) {
          activitiesData = body;
        } else if (body is Map) {
          activitiesData = body['activities'] ?? body['data'] ?? [];
        }
      }

      // If we got valid data from the main dashboard API, merge it with trends and activities
      if (dashboardData.isNotEmpty && (dashboardData['active_jobs'] != null || dashboardData['stats'] != null || dashboardData['total_applications'] != null)) {
        return {
          ...dashboardData,
          'analytics_data': trendsData.isNotEmpty ? trendsData : (dashboardData['analytics_data'] ?? []),
          'recent_activities': activitiesData.isNotEmpty ? activitiesData : (dashboardData['recent_activities'] ?? []),
        };
      }

      // Otherwise, fallback to aggregation but still use the new trends/activities if available
      final aggregated = await _aggregateDashboardData(token);
      return {
        ...aggregated,
        'analytics_data': trendsData.isNotEmpty ? trendsData : aggregated['analytics_data'],
        'recent_activities': activitiesData.isNotEmpty ? activitiesData : aggregated['recent_activities'],
      };

    } catch (e) {
      print('❌ Dashboard Service Error: $e');
      final auth = AuthService();
      final token = await auth.getToken();
      return await _aggregateDashboardData(token);
    }
  }

  Map<String, String> _headers(String? token) => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
    'X-Requested-With': 'XMLHttpRequest',
  };

  /// Aggregates data from multiple verified endpoints to populate the dashboard
  Future<Map<String, dynamic>> _aggregateDashboardData(String? token) async {
    print('🔄 Aggregating Dashboard Data from individual services...');
    
    // Fetch data in parallel for speed
    final results = await Future.wait([
      JobService.getEmployerJobs(),
      JobService.getEmployerApplications(),
    ]);
    
    final List<dynamic> jobs = results[0];
    final List<dynamic> applications = results[1];
    
    print('📊 Aggregation complete: ${jobs.length} jobs, ${applications.length} applications found.');

    // Calculate stats
    int activeJobsCount = jobs.where((j) => 
      j['status']?.toString().toLowerCase() == 'active' || 
      j['status']?.toString().toLowerCase() == 'published' ||
      j['verified'] == 1
    ).length;
    
    if (activeJobsCount == 0 && jobs.isNotEmpty) activeJobsCount = jobs.length;

    final int totalApplicationsCount = applications.length;
    
    final int newApplicationsCount = applications.where((a) {
      final status = a['status']?.toString().toLowerCase() ?? '';
      return status == 'new' || status == 'pending' || status == 'applied' || status == 'submitted' || status == 'unread';
    }).length;
    
    final int interviewsCount = applications.where((a) => 
      a['status']?.toString().toLowerCase() == 'interview' || 
      a['status']?.toString().toLowerCase() == 'shortlisted'
    ).length;

    // Build Recent Activities from Applications (Sorted by Date)
    final List<dynamic> sortedApps = List.from(applications);
    sortedApps.sort((a, b) {
      final dateA = DateTime.tryParse(a['applied_at']?.toString() ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['applied_at']?.toString() ?? '') ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    final List<Map<String, dynamic>> activities = [];
    for (var app in sortedApps.take(10)) {
      final candidate = app['candidate'] ?? {};
      final job = app['job'] ?? {};
      activities.add({
        'type': 'application',
        'title': candidate['full_name'] ?? app['candidate_name'] ?? 'A candidate',
        'subtitle': 'applied for ${job['title'] ?? app['job_title'] ?? 'your job'}',
        'time': app['applied_at'] ?? app['created_at'] ?? 'Just now',
        'created_at': app['applied_at'] ?? app['created_at'],
      });
    }

    // Build Analytics Data (Real 30 day trend from applications)
    final List<Map<String, dynamic>> analytics = [];
    final now = DateTime.now();
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final count = applications.where((a) {
        final appliedAt = a['applied_at'] ?? a['created_at'];
        if (appliedAt == null) return false;
        final appliedAtStr = appliedAt.toString();
        
        try {
          final appDate = DateTime.parse(appliedAtStr);
          return appDate.year == date.year && appDate.month == date.month && appDate.day == date.day;
        } catch (_) {
          return appliedAtStr.startsWith(dateStr);
        }
      }).length;
      analytics.add({'date': dateStr, 'count': count, 'value': count.toDouble()});
    }

    // Build Recent Jobs with real application counts
    final List<Map<String, dynamic>> recentJobs = jobs.take(5).map((j) {
      final jobId = j['id']?.toString();
      final count = applications.where((a) => a['job_id']?.toString() == jobId).length;
      return {
        'id': j['id'],
        'title': j['title'] ?? 'Job Title',
        'location': j['location'] ?? 'Location not specified',
        'status': j['status'] ?? 'Published',
        'created_at': j['created_at'] ?? 'Posted recently',
        'applications_count': count,
      };
    }).toList();

    return {
      'active_jobs': activeJobsCount,
      'total_jobs': jobs.length,
      'total_applications': totalApplicationsCount,
      'new_applications': newApplicationsCount,
      'interviews_scheduled': interviewsCount,
      'recent_jobs': recentJobs,
      'recent_activities': activities,
      'analytics_data': analytics,
    };
  }
}
