import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/core/theme/app_theme.dart';
import 'package:actibind/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class App extends StatelessWidget {
  const App({super.key});

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
      home: const HomePage(),
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
