import 'package:actibind/features/auth/services/auth_service.dart';
import 'package:actibind/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage(
      onSignOut: () async {
        try {
          await AuthService.signOut();
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
      },
    );
  }
}
