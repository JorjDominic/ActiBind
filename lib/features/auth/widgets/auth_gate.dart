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
        final session = AuthService.currentSession;
        if (session != null) {
          return _SessionValidation(key: ValueKey(session.accessToken));
        }
        return const LoginPage();
      },
    );
  }
}

class _SessionValidation extends StatefulWidget {
  const _SessionValidation({super.key});

  @override
  State<_SessionValidation> createState() => _SessionValidationState();
}

class _SessionValidationState extends State<_SessionValidation> {
  late final Future<bool> _validation = AuthService.validateCurrentSession();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _validation,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) return const DashboardPage();
        return const LoginPage();
      },
    );
  }
}
