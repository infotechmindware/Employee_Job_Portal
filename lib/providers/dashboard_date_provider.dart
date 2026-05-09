import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void setDate(DateTime date) {
    state = date;
  }
}

final dashboardDateProvider = NotifierProvider<DashboardDateNotifier, DateTime>(DashboardDateNotifier.new);
