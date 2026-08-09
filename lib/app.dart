import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/core/theme/app_theme.dart';
import 'package:actibind/features/auth/widgets/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class App extends StatelessWidget {
  const App({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return shad.ShadcnApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: const shad.ThemeData(
        colorScheme: shad.ColorSchemes.lightSlate,
        radius: 0.75,
      ),
      materialTheme: AppTheme.lightTheme,
      scrollBehavior: const _ClampedScrollBehavior(),
      home: home ?? const AuthGate(),
    );
  }
}

class _ClampedScrollBehavior extends MaterialScrollBehavior {
  const _ClampedScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
