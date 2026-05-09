import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/job_service.dart';

class EmployerJobsState {
  final List<dynamic> jobs;
  final List<dynamic> applications;

  EmployerJobsState({this.jobs = const [], this.applications = const []});

  EmployerJobsState copyWith({List<dynamic>? jobs, List<dynamic>? applications}) {
    return EmployerJobsState(
      jobs: jobs ?? this.jobs,
      applications: applications ?? this.applications,
    );
  }
}

class EmployerJobsNotifier extends Notifier<AsyncValue<EmployerJobsState>> {
  Timer? _timer;

  @override
  AsyncValue<EmployerJobsState> build() {
    // Start fetching when the provider is first read
    Future.microtask(() => fetchAll());
    
    // Set up a polling timer to keep data fresh (every 30 seconds)
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => fetchAll(showLoading: false));
    
    ref.onDispose(() {
      _timer?.cancel();
    });

    return const AsyncValue.loading();
  }

  Future<void> fetchAll({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncValue.loading();
    }
    try {
      final allJobs = await JobService.getEmployerJobs();
      final applications = await JobService.getEmployerApplications();
      
      // Filter jobs to remove duplicates and show only real published jobs
      final seenIds = <String>{};
      final filteredJobs = allJobs.where((job) {
        if (job == null) return false;
        
        final id = job['id']?.toString();
        if (id == null || seenIds.contains(id)) return false;
        
        seenIds.add(id);
        return true;
      }).toList();

      state = AsyncValue.data(EmployerJobsState(jobs: filteredJobs, applications: applications));
    } catch (e, st) {
      if (showLoading) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> toggleJobStatus(int jobId, bool isCurrentlyPublished) async {
    try {
      bool success;
      if (isCurrentlyPublished) {
        success = await JobService.unpublishJob(jobId);
      } else {
        success = await JobService.publishJob(jobId);
      }
      
      if (success) {
        await fetchAll(showLoading: false);
      }
    } catch (e) {
      print('Error toggling job status: $e');
    }
  }
}

final employerJobsProvider = NotifierProvider<EmployerJobsNotifier, AsyncValue<EmployerJobsState>>(EmployerJobsNotifier.new);
