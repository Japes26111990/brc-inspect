import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  void login(BuildContext context) {
    bool success = AuthService.login(
      username: usernameController.text,
      password: passwordController.text,
    );

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(color: AppColors.background),

        child: Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(30),

            decoration: BoxDecoration(
              color: AppColors.panel,

              borderRadius: BorderRadius.circular(28),

              border: Border.all(color: AppColors.gold, width: 1.5),

              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// LOGO
                Image.asset(
                  'assets/logos/brc_logo.png',
                  height: 140,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 10),

                const Text(
                  'VEHICLE INSPECTION PLATFORM',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 40),

                /// USERNAME
                TextField(
                  controller: usernameController,

                  textInputAction: TextInputAction.next,

                  decoration: const InputDecoration(
                    hintText: 'Username',

                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppColors.gold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// PASSWORD
                TextField(
                  controller: passwordController,

                  obscureText: true,

                  textInputAction: TextInputAction.done,

                  onSubmitted: (_) {
                    login(context);
                  },

                  decoration: const InputDecoration(
                    hintText: 'Password',

                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.gold),

                    suffixIcon: Icon(
                      Icons.visibility_outlined,
                      color: AppColors.gold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 60,

                  child: ElevatedButton(
                    onPressed: () {
                      login(context);
                    },

                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 45),

                /// APPROVALS
                const ApprovalRow(title: 'AA APPROVED'),

                const SizedBox(height: 18),

                const ApprovalRow(title: 'RMI APPROVED'),

                const SizedBox(height: 18),

                const ApprovalRow(title: 'SABS APPROVED'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ApprovalRow extends StatelessWidget {
  final String title;

  const ApprovalRow({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.goldDark)),

        const SizedBox(width: 14),

        const Icon(
          Icons.verified_user_outlined,
          color: AppColors.gold,
          size: 24,
        ),

        const SizedBox(width: 12),

        Text(
          title,

          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(child: Container(height: 1, color: AppColors.goldDark)),
      ],
    );
  }
}
