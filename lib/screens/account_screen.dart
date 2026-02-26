import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/provider/auth_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
      ),
      body: Center(
        child: authState.isAuthenticated
            ? Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_user,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "You are logged in ✅",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(authProvider.notifier)
                          .logout();
                      Navigator.pop(context);
                    },
                    child: const Text("Logout"),
                  ),
                ],
              )
            : const Text("Not logged in"),
      ),
    );
  }
}