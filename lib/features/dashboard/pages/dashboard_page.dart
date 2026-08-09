import 'package:actibind/features/auth/services/auth_service.dart';
import 'package:actibind/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final metadataName = user?.userMetadata?['full_name'] as String?;
    final emailName = user?.email?.split('@').first;
    final displayName = _formatName(metadataName ?? emailName ?? 'there');

    return HomePage(
      displayName: displayName,
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

  String _formatName(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[._-]+'), ' ');
    if (cleaned.isEmpty) return 'there';
    return cleaned
        .split(RegExp(r'\s+'))
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
