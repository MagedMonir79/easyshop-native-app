import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/user_service.dart';
import '../model/user_model.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  final userService = ref.read(userServiceProvider);
  return UserNotifier(userService);
});

class UserNotifier extends StateNotifier<UserModel?> {
  final UserService _userService;

  // ✅🔥 إضافة SecureStorage لقراءة الاسم المخزن
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserNotifier(this._userService) : super(null);

  /// 👤 Fetch current logged in user
  Future<void> fetchCurrentUser() async {
    try {
      final data = await _userService.getCurrentUser();

      if (data != null) {
        state = UserModel.fromJson(data);
        print("🟢 USER LOADED: ${state!.name}");
      } else {
        print("⚠️ API FAILED — Trying SecureStorage...");

        // ✅🔥 fallback: قراءة الاسم المخزن
        final storedName = await _storage.read(key: "user_name");

        final storedEmail = await _storage.read(key: "user_email");

        if (storedName != null && storedName.isNotEmpty) {
          state = UserModel(
            id: 0,
            name: storedName,
            email: storedEmail ?? "",
            roles: ["customer"],
          );

          print("🟢 USER LOADED FROM STORAGE: $storedName");
        } else {
          state = null;
          print("❌ USER NULL");
        }
      }
    } catch (e) {
      print("🔥 USER PROVIDER ERROR: $e");

      // ✅🔥 fallback في حالة exception
      final storedName = await _storage.read(key: "user_name");

      if (storedName != null && storedName.isNotEmpty) {
        state = UserModel(
          id: 0,
          name: storedName,
          email: "",
          roles: ["customer"],
        );

        print("🟢 USER LOADED FROM STORAGE (EXCEPTION): $storedName");
      } else {
        state = null;
      }
    }
  }

  /// 🚪 Clear user on logout
  void clearUser() {
    state = null;
  }
}
