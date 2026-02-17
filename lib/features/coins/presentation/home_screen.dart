import '../../../ui/home/home_screen.dart' as canonical;

/// Legacy compatibility wrapper.
///
/// Keep this file in place during consolidation so existing imports keep
/// compiling while routing and callsites migrate to `lib/ui/home/home_screen.dart`.
class HomeScreen extends canonical.HomeScreen {
  const HomeScreen({super.key});
}
