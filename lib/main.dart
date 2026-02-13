import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/supabase/supabase_config.dart';
import 'media/asset_resolver.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Keep app startup resilient even when local .env is absent/misconfigured.
  }

  await SupabaseConfig.initialize();

  await Hive.initFlutter();
  await AssetResolver.load();

  runApp(const ProviderScope(child: MarskyApp()));
}
