import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/brand/brand.dart';
import '../ui/theme/app_theme.dart';
import 'router.dart';

class MarskyApp extends ConsumerWidget {
  const MarskyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: KoraBrand.appName,
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    );
  }
}
