import 'package:actibind/features/auth/pages/login_page.dart';
import 'package:actibind/features/auth/services/auth_service.dart';
import 'package:actibind/features/dashboard/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (AuthService.currentSession != null) return const DashboardPage();
        return const LoginPage();
      },
    );
  }
}
