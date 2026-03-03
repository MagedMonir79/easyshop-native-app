import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(
      isLoading: true, // ✅ يبدأ Loading
      isAuthenticated: false,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated:
          isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;

  AuthNotifier(this.authService)
      : super(AuthState.initial()) {
    checkLoginStatus(); // ✅ يتنفذ تلقائي عند بدء التطبيق
  }

  Future<void> login(
      String email, String password) async {

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    final token =
        await authService.login(email, password);

    if (token != null && token.isNotEmpty) {

      state = const AuthState(
        isLoading: false,
        isAuthenticated: true,
      );

    } else {
      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: "Invalid email or password",
      );
    }
  }

  Future<void> checkLoginStatus() async {

    final token = await authService.getToken();

    if (token != null && token.isNotEmpty) {

      state = const AuthState(
        isLoading: false,
        isAuthenticated: true,
      );

    } else {

      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
      );
    }
  }

  Future<void> logout() async {
    await authService.logout();

    state = const AuthState(
      isLoading: false,
      isAuthenticated: false,
    );
  }
}