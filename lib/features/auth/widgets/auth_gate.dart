import 'package:actibind/features/auth/pages/login_page.dart';
import 'package:actibind/features/auth/services/auth_service.dart';
import 'package:actibind/features/dashboard/pages/dashboard_page.dart';
import 'package:actibind/features/family/presentation/pages/child_mode_setup_page.dart';
import 'package:actibind/features/family/services/child_mode_session_service.dart';
import 'package:actibind/features/family/services/device_policy_service.dart';
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

        if (snapshot.data == true) return const _ProtectedSessionGate();
        return const LoginPage();
      },
    );
  }
}

class _ProtectedSessionGate extends StatefulWidget {
  const _ProtectedSessionGate();

  @override
  State<_ProtectedSessionGate> createState() => _ProtectedSessionGateState();
}

class _ProtectedSessionGateState extends State<_ProtectedSessionGate> {
  late final Future<_RestoredChildMode?> _restored = _restore();
  bool _ended = false;

  Future<_RestoredChildMode?> _restore() async {
    final session = await ChildModeSessionService.load();
    if (session == null) return null;
    final policyService = AndroidDevicePolicyService.supported;
    final apps = await policyService.installedApps();
    return _RestoredChildMode(
      session: session,
      policyService: policyService,
      allowedApps: apps
          .where((app) => session.allowedPackages.contains(app.packageName))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_RestoredChildMode?>(
    future: _restored,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (_ended) return const DashboardPage();
      final restored = snapshot.data;
      if (restored == null) return const DashboardPage();
      return ActiveChildModePage(
        childName: restored.session.childName,
        minutes: restored.session.remainingMinutes,
        allowedCount: restored.allowedApps.length,
        restrictedCount: restored.session.restrictedCount,
        allowedApps: restored.allowedApps,
        policyService: restored.policyService,
        onEnded: () => setState(() => _ended = true),
      );
    },
  );
}

class _RestoredChildMode {
  const _RestoredChildMode({
    required this.session,
    required this.policyService,
    required this.allowedApps,
  });

  final ChildModeSession session;
  final DevicePolicyService policyService;
  final List<ChildModeApp> allowedApps;
}
