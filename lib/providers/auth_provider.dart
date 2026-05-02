import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final String? token;

  AuthState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.token,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    String? token,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    return AuthState();
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _authService.login(identifier, password);
    
    if (result['success']) {
      state = state.copyWith(isLoading: false, isSuccess: true, token: result['data']['token']);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    }
  }

  Future<bool> registerEmployer({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _authService.registerEmployer(
      fullName: fullName,
      mobile: mobile,
      email: email,
      password: password,
    );
    
    if (result['success']) {
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _authService.forgotPassword(email);
    
    if (result['success']) {
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authService.logout();
    state = AuthState(); // Reset state
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
