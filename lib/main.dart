import 'package:actibind/app.dart';
import 'package:actibind/core/config/supabase_config.dart';
import 'package:actibind/core/settings/family_mode_controller.dart';
import 'package:actibind/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
  await FamilyModeController.instance.load();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  runApp(const App());
}
