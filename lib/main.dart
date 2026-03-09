import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/view/auth_gate.dart';

void main() {
  runApp(const ProviderScope(child: EasyShopApp()));
}

class EasyShopApp extends StatelessWidget {
  const EasyShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
