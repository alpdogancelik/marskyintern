# QA Media Checklist

Scope:
- Media resolver + UI primitives integration
- Screens updated in this pass:
  - `lib/features/coins/presentation/home_screen.dart`
  - `lib/features/favorites/presentation/favorites_screen.dart`
  - `lib/features/coins/presentation/coin_detail_sheet.dart`

## 1) Performance Gate

### Checks
- [x] List screens use builder-based virtualization.
- [x] Heavy media (illustrations) are deferred/lazy loaded.
- [x] Reduced work on image decode for raster illustrations.
- [x] No eager SVG directory import pattern in feature code.

### Verify (commands)
```powershell
rg -n "ListView\.builder|RefreshIndicator|showModalBottomSheet" lib/features/coins/presentation/home_screen.dart lib/features/favorites/presentation/favorites_screen.dart lib/features/coins/presentation/coin_detail_sheet.dart
rg -n "recommendDeferredLoadingForContext|RepaintBoundary|cacheWidth|cacheHeight" lib/core/widgets/illustration.dart
rg -n "import .*lib/media/svg" lib
```

### Result (this run)
- PASS: `ListView.builder` present in markets + portfolio + selector lists.
- PASS: Illustration widget uses deferred loading and `RepaintBoundary`.
- PASS: Raster illustration rendering sets `cacheWidth/cacheHeight`.
- PASS: No eager directory import pattern for `lib/media/svg` in Dart imports.

## 2) Accessibility Gate

### Checks
- [x] Icon primitive requires semantic labels.
- [x] Interactive icon buttons in touched screens include tooltips/labels.
- [x] Focus-visible affordance for custom tap surfaces.
- [x] Reduced motion respected in media primitives.
- [ ] Contrast in light/dark manually reviewed on running app build.

### Verify (commands)
```powershell
rg -n "class AppIcon|required this.semanticLabel" lib/core/widgets/app_icon.dart
rg -n "IconButton\(" lib/features/coins/presentation/home_screen.dart lib/features/favorites/presentation/favorites_screen.dart lib/features/coins/presentation/coin_detail_sheet.dart
rg -n "focusColor" lib/features/coins/presentation/coin_detail_sheet.dart
rg -n "disableAnimations|AnimatedSwitcher" lib/core/widgets/coin_logo.dart lib/core/widgets/app_icon.dart lib/core/widgets/illustration.dart
```

### Result (this run)
- PASS: `AppIcon` enforces `semanticLabel`.
- PASS: Touched interactive icon controls include tooltip/semantic labels.
- PASS: Custom selector tap surface uses `focusColor`.
- PASS: Reduced-motion handling implemented via `disableAnimations`.
- BLOCKED (env): Runtime contrast validation needs app launch in light/dark themes.

## 3) Consistency Gate

### Checks
- [x] `AppIcon` size scale normalized to 20/24.
- [x] `CoinLogo` size scale normalized to 16/20/24/32/48.
- [x] Updated empty screens use canonical `EmptyState`.
- [x] Coin logos rendered in normalized container.

### Verify (commands)
```powershell
rg -n "supportedSizes" lib/core/widgets/app_icon.dart lib/core/widgets/coin_logo.dart
rg -n "EmptyState\(" lib/features/coins/presentation/home_screen.dart lib/features/favorites/presentation/favorites_screen.dart
rg -n "CoinLogo\(" lib/features/coins/presentation/home_screen.dart lib/features/favorites/presentation/favorites_screen.dart lib/features/coins/presentation/coin_detail_sheet.dart
```

### Result (this run)
- PASS: `AppIcon.supportedSizes = [20, 24]`.
- PASS: `CoinLogo.supportedSizes = [16, 20, 24, 32, 48]`.
- PASS: Markets/Portfolio empty cases use `EmptyState`.
- PASS: Coin identity surfaces use `CoinLogo` consistently.

## Build/Lint/Test status

Commands attempted:
```powershell
flutter analyze
flutter test
```

Result:
- BLOCKED (environment): `flutter` is not available on PATH in this execution environment.
- Mitigation used: static QA checks via `rg` and targeted code inspection for media-integration scope.
