import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/features/home/presentation/pages/home_page.dart';
import 'package:forui/forui.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.neutral.light.touch;

    return MaterialApp(
      title: AppConstants.appName,
      theme: theme.toApproximateMaterialTheme(),
      home: FTheme(
        data: theme,
        child: const HomePage(),
      ),
    );
  }
}
