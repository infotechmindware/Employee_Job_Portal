import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final int activeIndex;
  final int profileStep;

  NavigationState({
    required this.activeIndex,
    this.profileStep = 0,
  });

  NavigationState copyWith({
    int? activeIndex,
    int? profileStep,
  }) {
    return NavigationState(
      activeIndex: activeIndex ?? this.activeIndex,
      profileStep: profileStep ?? this.profileStep,
    );
  }
}

class NavigationNotifier extends Notifier<NavigationState> {
  @override
  NavigationState build() => NavigationState(activeIndex: -1);
  
  void setIndex(int index) {
    state = state.copyWith(activeIndex: index);
  }

  void setProfileStep(int step) {
    state = state.copyWith(profileStep: step);
  }
}

final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState>(NavigationNotifier.new);
