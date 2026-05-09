import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dashboard_service.dart';

final dashboardServiceProvider = Provider((ref) => DashboardService());

final dashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return await service.getDashboardData();
});
