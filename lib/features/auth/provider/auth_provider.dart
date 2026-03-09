import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_service.dart';
import '../../user/provider/user_provider.dart';
// 🔥 جديد: هنستخدمه لاحقًا لما نربط الكارت
import '../../cart/provider/cart_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService, ref);
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
    return const AuthState(isLoading: true, isAuthenticated: false);
  }

  AuthState copyWith({bool? isLoading, bool? isAuthenticated, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;
  final Ref ref;

  AuthNotifier(this.authService, this.ref) : super(AuthState.initial()) {
    checkLoginStatus();
  }

  /// 🔐 LOGIN
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final token = await authService.login(email, password);

    if (token != null && token.isNotEmpty) {
      state = const AuthState(isLoading: false, isAuthenticated: true);

      // 🟢 Fetch user immediately after login
      await ref.read(userProvider.notifier).fetchCurrentUser();

      // 🔥🔥 بعد تسجيل الدخول نعيد تحميل السلة من السيرفر
      try {
        await ref.read(cartProvider.notifier).loadCart();
      } catch (_) {}
    } else {
      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: "Invalid email or password",
      );
    }
  }

  /// 🔍 CHECK STORED TOKEN (محسنة بالأمان)
  Future<void> checkLoginStatus() async {
    state = state.copyWith(isLoading: true);

    final isValid = await authService.validateStoredToken();

    if (isValid) {
      state = const AuthState(isLoading: false, isAuthenticated: true);

      // 🟢 Auto fetch user on app start
      await ref.read(userProvider.notifier).fetchCurrentUser();

      // 🔥🔥 تحميل السلة تلقائيًا لو المستخدم مسجل دخول
      try {
        await ref.read(cartProvider.notifier).loadCart();
      } catch (_) {}
    } else {
      await authService.clearAllAuthData();

      state = const AuthState(isLoading: false, isAuthenticated: false);
    }
  }

  /// 🚪 LOGOUT (محسنة لحل مشكلة السلة)
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    await authService.logout();

    // 🔴 Clear user state
    ref.read(userProvider.notifier).clearUser();

    // 🔥🔥 مهم جدًا — Reset أي Provider مربوط بالمستخدم
    try {
      ref.invalidate(userProvider);
    } catch (_) {}

    try {
      ref.invalidate(authServiceProvider);
    } catch (_) {}

    // 🔥🔥🔥 السطر المهم لحل مشكلة بقاء السلة
    try {
      ref.invalidate(cartProvider);
    } catch (_) {}

    state = const AuthState(isLoading: false, isAuthenticated: false);
  }
}
