import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_colors.dart';
import '../../services/job_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/common/custom_avatar.dart';
import '../candidates/candidate_details_screen.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InterviewsScreen extends ConsumerStatefulWidget {
  const InterviewsScreen({super.key});

  @override
  ConsumerState<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends ConsumerState<InterviewsScreen> {
  int _selectedTab = 0;
  String _selectedType = 'All Types';
  String _selectedSort = 'Latest First';

  List<dynamic> _interviews = [];
  Map<String, dynamic> _apiStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInterviews();
  }

  Future<void> _fetchInterviews({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
        _interviews = []; // Clear old list before loading new data
      });
    }

    final tabName = _tabs[_selectedTab];
    String? statusParam;
    if (tabName == 'All') {
      statusParam = 'all';
    } else if (tabName == 'Upcoming') {
      statusParam = 'upcoming';
    } else if (tabName == 'Today') {
      statusParam = 'today';
    } else if (tabName == 'This Week') {
      statusParam = 'week';
    } else if (tabName == 'Completed') {
      statusParam = 'completed';
    } else if (tabName == 'Declined') {
      statusParam = 'cancelled';
    }

    final result = await JobService.getEmployerInterviews(status: statusParam);
    if (mounted) {
      setState(() {
        _interviews = result['interviews'] ?? [];
        _apiStats = result['stats'] ?? {};
        _isLoading = false;
      });
    }
  }

  Future<void> _joinInterviewRoom(
    String roomName,
    String userName,
    String email,
  ) async {
    try {
      // Request runtime permissions before joining
      await Permission.camera.request();
      await Permission.microphone.request();

      // Ensure roomName is valid (unique, no spaces, no special symbols)
      // Standardizing to use snake_case / alphanumeric characters only
      final cleanRoomName = roomName
          .trim()
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

      print('🚀 Joining Native Jitsi Room: $cleanRoomName on meet.jit.si as $userName ($email)');
      await JitsiMeetWrapper.joinMeeting(
        options: JitsiMeetingOptions(
          roomNameOrUrl: cleanRoomName,
          serverUrl: "https://meet.jit.si",
          userDisplayName: userName,
          userEmail: email,
          isAudioMuted: false,
          isVideoMuted: false,
        ),
      );
    } catch (e) {
      print('❌ Native Jitsi Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join interview room: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRescheduleDialog(dynamic interview) async {
    final id = interview['id'];
    if (id == null) return;

    Map<String, dynamic> details = interview is Map<String, dynamic> 
        ? interview 
        : Map<String, dynamic>.from(interview);

    DateTime? selectedDate;
    TimeOfDay? selectedStartTime;
    TimeOfDay? selectedEndTime;
    String selectedTimezone = details['timezone']?.toString() ?? 'Asia/Kolkata (IST)';
    if (selectedTimezone.isEmpty) selectedTimezone = 'Asia/Kolkata (IST)';
    final locationController = TextEditingController(text: details['location']?.toString() ?? '');
    final meetingLinkController = TextEditingController(text: details['meeting_url']?.toString() ?? details['meeting_link']?.toString() ?? '');

    try {
      if (details['scheduled_start'] != null) {
        final start = DateTime.parse(details['scheduled_start']);
        selectedDate = start;
        selectedStartTime = TimeOfDay.fromDateTime(start);
      } else if (details['date'] != null && details['start_time'] != null) {
        final start = DateTime.parse('${details['date']} ${details['start_time']}');
        selectedDate = start;
        selectedStartTime = TimeOfDay.fromDateTime(start);
      }
      if (details['scheduled_end'] != null) {
        final end = DateTime.parse(details['scheduled_end']);
        selectedEndTime = TimeOfDay.fromDateTime(end);
      } else if (details['date'] != null && details['end_time'] != null) {
        final end = DateTime.parse('${details['date']} ${details['end_time']}');
        selectedEndTime = TimeOfDay.fromDateTime(end);
      }
    } catch (_) {}

    final List<String> timezones = [
      'Asia/Kolkata (IST)',
      'America/New_York (EST)',
      'Europe/London (GMT)',
      'Australia/Sydney (AEST)',
      'UTC'
    ];
    if (!timezones.contains(selectedTimezone)) timezones.add(selectedTimezone);

    if (mounted) {
      await showDialog(
        context: context,
        builder: (dialogCtx) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final theme = Theme.of(context);
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Container(
                  width: 500,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reschedule Interview',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(LucideIcons.x, size: 20),
                              onPressed: () => Navigator.pop(dialogCtx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        Text('Date *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setDialogState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate == null ? 'Select Date' : DateFormat('dd-MM-yyyy').format(selectedDate!),
                                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13),
                                ),
                                const Icon(LucideIcons.calendar, size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Start Time *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: selectedStartTime ?? TimeOfDay.now(),
                                      );
                                      if (time != null) {
                                        setDialogState(() => selectedStartTime = time);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            selectedStartTime == null ? 'Time' : selectedStartTime!.format(context),
                                            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13),
                                          ),
                                          const Icon(LucideIcons.clock, size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('End Time *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: selectedEndTime ?? (selectedStartTime != null ? selectedStartTime!.replacing(hour: (selectedStartTime!.hour + 1) % 24) : TimeOfDay.now()),
                                      );
                                      if (time != null) {
                                        setDialogState(() => selectedEndTime = time);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            selectedEndTime == null ? 'Time' : selectedEndTime!.format(context),
                                            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13),
                                          ),
                                          const Icon(LucideIcons.clock, size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Text('Timezone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedTimezone,
                              icon: const Icon(LucideIcons.chevronDown, size: 16),
                              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                              dropdownColor: theme.cardColor,
                              items: timezones.map((tz) => DropdownMenuItem(value: tz, child: Text(tz))).toList(),
                              onChanged: (val) {
                                if (val != null) setDialogState(() => selectedTimezone = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Text('Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: locationController,
                          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFF97316))),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Text('Meeting Link', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: meetingLinkController,
                          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFF97316))),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: theme.dividerColor.withOpacity(0.2))),
                                foregroundColor: theme.colorScheme.onSurface,
                              ),
                              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: (selectedDate == null || selectedStartTime == null || selectedEndTime == null) ? null : () async {
                                Navigator.pop(dialogCtx);
                                
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                                );
                                
                                bool success = false;
                                String errorMsg = '';
                                
                                try {
                                  final startDateTime = DateTime(
                                    selectedDate!.year, selectedDate!.month, selectedDate!.day,
                                    selectedStartTime!.hour, selectedStartTime!.minute,
                                  );
                                  final endDateTime = DateTime(
                                    selectedDate!.year, selectedDate!.month, selectedDate!.day,
                                    selectedEndTime!.hour, selectedEndTime!.minute,
                                  );
                                  
                                  final Map<String, dynamic> rescheduleData = {
                                    'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
                                    'start_time': '${selectedStartTime!.hour.toString().padLeft(2, '0')}:${selectedStartTime!.minute.toString().padLeft(2, '0')}',
                                    'end_time': '${selectedEndTime!.hour.toString().padLeft(2, '0')}:${selectedEndTime!.minute.toString().padLeft(2, '0')}',
                                    'scheduled_start': startDateTime.toIso8601String(),
                                    'scheduled_end': endDateTime.toIso8601String(),
                                    'timezone': selectedTimezone,
                                    'location': locationController.text.trim(),
                                    'meeting_link': meetingLinkController.text.trim(),
                                  };
                                  
                                  success = await JobService.rescheduleInterview(id, rescheduleData);
                                } catch (e) {
                                  success = false;
                                  errorMsg = e.toString();
                                } finally {
                                  if (mounted) Navigator.pop(context);
                                }
                                
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Interview rescheduled successfully!'), backgroundColor: Colors.green));
                                  _fetchInterviews(showLoader: false);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg.isNotEmpty ? 'Failed: $errorMsg' : 'Failed to reschedule.'), backgroundColor: Colors.red));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE85D04),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                elevation: 0,
                              ),
                              child: const Text('Reschedule Interview', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }

  Future<void> _confirmDeclineInterview(dynamic interview) async {
    final id = interview['id'];
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Interview', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to cancel this scheduled interview?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('No', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      final success = await JobService.cancelInterview(id);

      if (mounted) Navigator.pop(context); // Dismiss loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interview cancelled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchInterviews(showLoader: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel interview.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeInterviewFlow(dynamic interview) async {
    final id = interview['id'];
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Complete Interview', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Mark this interview as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      final success = await JobService.completeInterview(id);

      if (mounted) Navigator.pop(context); // Dismiss loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interview marked as completed!'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchInterviews(showLoader: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to complete interview.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  final List<String> _tabs = ['All', 'Upcoming', 'Today', 'This Week', 'Completed', 'Declined'];
  
  final List<String> _typeOptions = ['All Types', 'Technical', 'HR', 'Behavioral'];
  final List<String> _sortOptions = ['Latest First', 'Oldest First', 'A-Z', 'Z-A'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDesktop),
            const SizedBox(height: 32),
            _buildStatsCards(isDesktop),
            const SizedBox(height: 32),
            _buildTabAndFilters(isDesktop),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_interviews.isEmpty)
              _buildEmptyState()
            else
              _buildInterviewList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Interviews',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage and track all candidate interviews',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _showScheduleDialog(context),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Schedule Interview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  int get totalInterviews => _interviews.length;
  
  int get scheduledInterviews {
    return _interviews.where((i) {
      final status = i['status']?.toString().toLowerCase() ?? '';
      return status == 'upcoming' || status == 'scheduled' || status == 'live' || status == 'interviewing' || status == 'pending';
    }).length;
  }
  
  int get todayInterviews {
    final now = DateTime.now();
    return _interviews.where((i) {
      final start = i['scheduled_start']?.toString() ?? '';
      if (start.isEmpty) return false;
      try {
        final date = DateTime.parse(start);
        return date.year == now.year && date.month == now.month && date.day == now.day;
      } catch (e) {
        return false;
      }
    }).length;
  }

  int get next7DaysInterviews {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _interviews.where((i) {
      final start = i['scheduled_start']?.toString() ?? '';
      if (start.isEmpty) return false;
      try {
        final date = DateTime.parse(start);
        return date.isAfter(now) && date.isBefore(nextWeek);
      } catch (e) {
        return false;
      }
    }).length;
  }

  int get finishedInterviews {
    return _interviews.where((i) {
      final status = i['status']?.toString().toLowerCase() ?? '';
      return status == 'completed' || status == 'done' || status == 'finished';
    }).length;
  }

  int get declinedInterviews {
    return _interviews.where((i) {
      final status = i['status']?.toString().toLowerCase() ?? '';
      return status == 'declined' || status == 'missed' || status == 'cancelled' || status == 'withdrawn';
    }).length;
  }

  Widget _buildStatsCards(bool isDesktop) {
    final stats = [
      {'title': 'TOTAL', 'value': (_apiStats['total'] ?? totalInterviews).toString(), 'subtitle': 'All time', 'icon': LucideIcons.barChart2, 'color': const Color(0xFF64748B)},
      {'title': 'UPCOMING', 'value': (_apiStats['upcoming'] ?? scheduledInterviews).toString(), 'subtitle': 'Scheduled', 'icon': LucideIcons.calendar, 'color': const Color(0xFF6366F1)},
      {'title': 'TODAY', 'value': (_apiStats['today'] ?? todayInterviews).toString(), 'subtitle': 'Today', 'icon': LucideIcons.clock, 'color': const Color(0xFF3B82F6)},
      {'title': 'WEEK', 'value': (_apiStats['week'] ?? next7DaysInterviews).toString(), 'subtitle': 'Next 7 days', 'icon': LucideIcons.calendarDays, 'color': const Color(0xFF8B5CF6)},
      {'title': 'DONE', 'value': (_apiStats['completed'] ?? finishedInterviews).toString(), 'subtitle': 'Finished', 'icon': LucideIcons.checkCircle, 'color': const Color(0xFF10B981)},
      {'title': 'DECLINED', 'value': (_apiStats['missed'] ?? declinedInterviews).toString(), 'subtitle': 'Missed', 'icon': LucideIcons.xCircle, 'color': const Color(0xFFEF4444)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 6 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isDesktop ? 1.2 : 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return _buildStatCard(stats[index], isDesktop);
      },
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, bool isDesktop) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(stat['icon'] as IconData, size: 16, color: stat['color'] as Color),
              ),
              Text(
                stat['title'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stat['value'] as String,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['subtitle'] as String,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTabAndFilters(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabs(),
        const SizedBox(height: 24),
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
                boxShadow: theme.brightness == Brightness.light ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ] : [],
              ),
              child: Column(
                children: [
                  _buildSearchField(double.infinity),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDropdownField(_selectedType, _typeOptions, (val) => setState(() => _selectedType = val!), AlignmentDirectional.centerStart)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDropdownField(_selectedSort, _sortOptions, (val) => setState(() => _selectedSort = val!), AlignmentDirectional.centerEnd)),
                    ],
                  ),
                ],
              ),
            );
          }
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
                _fetchInterviews();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : theme.dividerColor.withOpacity(0.1),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchField(double width) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      height: 52,
      child: TextField(
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search interviews...',
          hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
          prefixIcon: Icon(LucideIcons.search, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          filled: true,
          fillColor: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor.withOpacity(0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String value, List<String> items, ValueChanged<String?> onChanged, AlignmentGeometry menuAlignment) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          alignment: menuAlignment,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: theme.cardColor,
          elevation: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          icon: Icon(LucideIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
          items: items.map((String val) => DropdownMenuItem<String>(
            value: val,
            alignment: menuAlignment,
            child: Text(val),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.calendar, size: 56, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          Text(
            'No Interviews Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule your first interview to get started.',
            style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showScheduleDialog(context),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Schedule Interview'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule Interview',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fill in the details to set up a new meeting',
                            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Form Fields
                _buildLabel('Select Candidate'),
                _buildDialogField(LucideIcons.user, 'Search candidate name...'),
                const SizedBox(height: 16),
                
                _buildLabel('Assign Interviewer'),
                _buildDialogDropdown(['Select Interviewer', 'Sarah Johnson (HR)', 'Michael Chen (Tech)', 'Emily Davis (Product)']),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Date'),
                          _buildDialogField(LucideIcons.calendar, 'Oct 24, 2026'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Time'),
                          _buildDialogField(LucideIcons.clock, '10:30 AM'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildLabel('Interview Mode'),
                _buildDialogDropdown(['Video Call (Google Meet)', 'In-Person (Office)', 'Phone Call']),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                          ),
                          foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Schedule', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
      ),
    );
  }

  Widget _buildDialogField(IconData icon, String hint) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: TextField(
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
          prefixIcon: Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDialogDropdown(List<String> items) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items[0],
          isExpanded: true,
          dropdownColor: theme.cardColor,
          items: items.map((String val) => DropdownMenuItem<String>(
            value: val,
            child: Text(val, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
          )).toList(),
          onChanged: (val) {},
          icon: Icon(LucideIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildInterviewList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _interviews.length,
      itemBuilder: (context, index) {
        final interview = _interviews[index];
        return _buildInterviewCard(interview);
      },
    );
  }

  Widget _buildInterviewCard(dynamic interview) {
    final candidate = interview['candidate'] ?? {};
    final job = interview['job'] ?? {};
    
    final candidateName = candidate['full_name'] ?? interview['candidate_name'] ?? 'Unknown Candidate';
    final company = interview['company'] ?? job['company'] ?? {};
    final companyLogo = company['logo'] ?? interview['company_logo'];
    final candidateImageRaw = candidate['profile_image'] ?? candidate['photo'] ?? candidate['image'] ?? candidate['avatar'] ?? interview['candidate_image'] ?? interview['candidate_photo'] ?? companyLogo;
    
    String? finalImageUrl = candidateImageRaw?.toString();
    if (finalImageUrl != null && finalImageUrl.isNotEmpty && !finalImageUrl.startsWith('http')) {
      finalImageUrl = finalImageUrl.startsWith('/') 
          ? 'https://www.mindwareinfotech.com$finalImageUrl'
          : 'https://www.mindwareinfotech.com/$finalImageUrl';
    }

    final jobTitle = job['title'] ?? interview['job_title'] ?? 'Unknown Job';
    
    final rawStatus = interview['status']?.toString()?.toLowerCase() ?? 'pending';
    final status = rawStatus.toUpperCase();
    final interviewType = interview['interview_type']?.toString() ?? 'Online';
    
    // Format Date & Time properly
    final String startStr = interview['scheduled_start']?.toString() ?? '';
    final String endStr = interview['scheduled_end']?.toString() ?? '';
    String formattedDateTime = 'TBD - TBD';
    
    if (startStr.isNotEmpty) {
      try {
        final startDate = DateTime.parse(startStr);
        final datePart = DateFormat('MMM dd, yyyy').format(startDate);
        final startTime = DateFormat('hh:mm a').format(startDate);
        formattedDateTime = '$datePart | $startTime';
        
        if (endStr.isNotEmpty) {
          final endDate = DateTime.parse(endStr);
          final endTime = DateFormat('hh:mm a').format(endDate);
          formattedDateTime += ' - $endTime';
        }
      } catch (e) {
        formattedDateTime = '$startStr - $endStr';
      }
    }

    final meetingLink = interview['meeting_link']?.toString() ?? '';
    final bool isLive = rawStatus == 'live' || rawStatus == 'interviewing';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic Badge Color mapping to exactly mirror premium Web styles
    Color badgeBgColor;
    Color badgeTextColor;
    if (rawStatus == 'live' || rawStatus == 'interviewing') {
      badgeBgColor = const Color(0xFFEEF2FF);
      badgeTextColor = const Color(0xFF4F46E5);
    } else if (rawStatus == 'scheduled' || rawStatus == 'rescheduled') {
      badgeBgColor = const Color(0xFFFEF2F2);
      badgeTextColor = const Color(0xFFEF4444);
    } else if (rawStatus == 'completed') {
      badgeBgColor = const Color(0xFFECFDF5);
      badgeTextColor = const Color(0xFF059669);
    } else if (rawStatus == 'cancelled' || rawStatus == 'declined') {
      badgeBgColor = const Color(0xFFF1F5F9);
      badgeTextColor = const Color(0xFF64748B);
    } else {
      badgeBgColor = const Color(0xFFF8FAFC);
      badgeTextColor = const Color(0xFF475569);
    }

    // Dynamic list of buttons to populate the Wrap layout
    final List<Widget> actionButtons = [];

    // 1. Join Button
    if (isLive || ((rawStatus == 'scheduled' || rawStatus == 'rescheduled') && meetingLink.isNotEmpty)) {
      actionButtons.add(
        ElevatedButton.icon(
          onPressed: () async {
            final id = interview['id'];
            if (id == null) return;
            
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
            
            try {
              final details = await JobService.getInterviewDetails(id);
              if (mounted) Navigator.pop(context); // Dismiss loading dialog
              
              if (details != null) {
                String? roomName = details['room_name']?.toString();
                
                if (roomName == null || roomName.isEmpty) {
                  final roomUrl = details['room_url'] ?? details['meeting_url'] ?? details['jitsi_url'] ?? details['meeting_link'];
                  if (roomUrl != null && roomUrl.toString().isNotEmpty) {
                    try {
                      final uri = Uri.parse(roomUrl.toString());
                      if (uri.pathSegments.isNotEmpty) {
                        if (uri.pathSegments.last == 'room' && uri.pathSegments.length >= 2) {
                          roomName = 'mindware-interview-${uri.pathSegments[uri.pathSegments.length - 2]}';
                        } else {
                          roomName = uri.pathSegments.last;
                        }
                      }
                    } catch (_) {}
                  }
                }
                
                if (roomName == null || roomName.isEmpty) {
                  roomName = 'mindware-interview-$id';
                }
                
                await _joinInterviewRoom(
                  roomName,
                  "Employer",
                  "employer@mindwareinfotech.com",
                );
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to fetch interview details.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } catch (e) {
              if (mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error joining room: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          icon: const Icon(LucideIcons.video, size: 12),
          label: const Text('Join', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444), // Match Web Red-Orange style
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            elevation: 0,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    }

    // 2. Complete Button
    if (rawStatus == 'scheduled' || rawStatus == 'rescheduled') {
      actionButtons.add(
        OutlinedButton.icon(
          onPressed: () => _completeInterviewFlow(interview),
          icon: const Icon(LucideIcons.check, size: 12, color: Color(0xFF10B981)),
          label: const Text('Complete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF10B981))),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFECFDF5),
            side: const BorderSide(color: Color(0xFFA7F3D0)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    }

    // 3. Reschedule Button
    if (rawStatus == 'scheduled' || rawStatus == 'rescheduled') {
      actionButtons.add(
        OutlinedButton.icon(
          onPressed: () => _showRescheduleDialog(interview),
          icon: const Icon(LucideIcons.calendar, size: 12, color: Color(0xFF059669)),
          label: const Text('Reschedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF059669))),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFECFDF5),
            side: const BorderSide(color: Color(0xFFA7F3D0)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    }

    // 4. Decline Button
    if (rawStatus == 'scheduled' || rawStatus == 'rescheduled') {
      actionButtons.add(
        OutlinedButton.icon(
          onPressed: () => _confirmDeclineInterview(interview),
          icon: const Icon(LucideIcons.x, size: 12, color: Color(0xFFEF4444)),
          label: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFEF4444))),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFFEF2F2),
            side: const BorderSide(color: Color(0xFFFCA5A5)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    }

    // 5. View Details Button
    actionButtons.add(
      ElevatedButton(
        onPressed: () {
          try {
            final appObj = interview['application'] ?? interview;
            final rawCandidateData = {
              if (appObj is Map) ...appObj,
              if (appObj['candidate'] != null || interview['candidate'] != null)
                'candidate': appObj['candidate'] ?? interview['candidate'],
              if (appObj['job'] != null || interview['job'] != null)
                'job': appObj['job'] ?? interview['job'],
            };
            
            final Map<String, dynamic> safeCandidateData = Map<String, dynamic>.from(
              jsonDecode(jsonEncode(rawCandidateData))
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CandidateDetailsScreen(candidate: safeCandidateData),
              ),
            );
          } catch (e) {
            print('Navigation Error: $e');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF97316), // Match Premium Orange Style
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? theme.dividerColor.withOpacity(0.1) : const Color(0xFFF1F5F9), width: 1.0),
        boxShadow: !isDark ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF1F5F9),
                ),
                child: finalImageUrl != null && finalImageUrl.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: finalImageUrl,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Text(
                              candidateName.isNotEmpty ? candidateName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.primary),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          candidateName.isNotEmpty ? candidateName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.primary),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidateName,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: theme.colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      jobTitle,
                      style: const TextStyle(color: Color(0xFF888888), fontSize: 12, fontWeight: FontWeight.w400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: badgeTextColor, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(LucideIcons.video, 'Type: ', interviewType.toLowerCase()),
          const SizedBox(height: 6),
          _buildInfoRow(LucideIcons.calendar, 'Date & Time: ', formattedDateTime),
          const SizedBox(height: 16),
          // Align dynamic actions properly using Wrap layout
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: actionButtons,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF666666)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF666666), fontSize: 11, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF444444), 
              fontSize: 11, 
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
