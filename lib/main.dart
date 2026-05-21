import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'modules/auth/screens/login_screen.dart';

void main() {
  runApp(const BRCInspectApp());
}

class BRCInspectApp extends StatelessWidget {
  const BRCInspectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BRC Inspect',
      theme: AppTheme.darkTheme,
      home: LoginScreen(),
    );
  }
}
