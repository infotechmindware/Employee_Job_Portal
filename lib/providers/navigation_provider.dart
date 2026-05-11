import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final int activeIndex;
  final int profileStep;
  final int applicationsTabIndex;

  NavigationState({
    required this.activeIndex,
    this.profileStep = 0,
    this.applicationsTabIndex = 0,
  });

  NavigationState copyWith({
    int? activeIndex,
    int? profileStep,
    int? applicationsTabIndex,
  }) {
    return NavigationState(
      activeIndex: activeIndex ?? this.activeIndex,
      profileStep: profileStep ?? this.profileStep,
      applicationsTabIndex: applicationsTabIndex ?? this.applicationsTabIndex,
    );
  }
}

class NavigationNotifier extends Notifier<NavigationState> {
  @override
  NavigationState build() => NavigationState(activeIndex: 0); // Default to Dashboard
  
  void setIndex(int index, {int? appTabIndex}) {
    state = state.copyWith(
      activeIndex: index,
      applicationsTabIndex: appTabIndex ?? 0,
    );
  }

  void setProfileStep(int step) {
    state = state.copyWith(profileStep: step);
  }

  void setApplicationsTabIndex(int index) {
    state = state.copyWith(applicationsTabIndex: index);
  }
}

final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState>(NavigationNotifier.new);
