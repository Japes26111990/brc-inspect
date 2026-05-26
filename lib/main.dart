import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'modules/auth/screens/login_screen.dart';
import 'modules/inspection/providers/inspection_provider.dart';

void main() {
  runApp(
    // 🌍 Initializes the master tracking state block at the absolute root apex
    ChangeNotifierProvider(
      create: (_) => ActiveInspectionProvider(),
      child: const BRCInspectApp(),
    ),
  );
}

class BRCInspectApp extends StatelessWidget {
  const BRCInspectApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎯 CRITICAL FIX: The MaterialApp builder block sits INSIDE the provider scope.
    // This makes the broadcast loop fully visible across all future Navigator pop/push views!
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BRC Inspect',
      theme:
          AppTheme.lightTheme, // 🌟 Instantly applies your new light palette!
      home: LoginScreen(),
    );
  }
}
