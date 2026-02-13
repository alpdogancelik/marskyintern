# Onboarding Spec

## Flow
- `/splash` -> `/onboarding` -> `/get-started-v1`
- Onboarding `Skip` goes to `/get-started-v1`
- Onboarding `Get Started` advances PageView; on last page it goes to `/get-started-v1`
- Onboarding `Browse Assets` opens `/get-started-v2`
- Get Started Email -> `/login`
- Get Started Sign Up -> `/register`
- Apple/Google -> snackbar stub (`Coming soon`)

## Layout Rules
- Base background uses `ColorScheme.surfaceContainerLowest` for a light gray surface.
- Page content uses a white card-like treatment (`AppCard`) with subtle border/shadow.
- Horizontal padding: `20`
- Section spacing: tokenized (`AppTokens.space*`), with larger gaps around hero/title.
- CTA height: `50` (`AppTokens.buttonHeight` / `socialButtonHeight`)
- Radius: medium/large tokenized (`14`, `18`, `24`)
- Skip button is outlined pill (`AppPillButton`) with min target `44x44`.
- No overflow on small screens: onboarding/get-started are wrapped in `SingleChildScrollView + ConstrainedBox`.

## Components
- Theme/tokens: `lib/ui/theme/app_theme.dart`, `lib/ui/theme/app_tokens.dart`
- UI kit: `lib/ui/kit/app_scaffold.dart`, `lib/ui/kit/app_top_bar.dart`, `lib/ui/kit/app_card.dart`, `lib/ui/kit/app_buttons.dart`, `lib/ui/kit/app_divider.dart`
- Onboarding:
  - `lib/ui/onboarding/splash_screen.dart`
  - `lib/ui/onboarding/onboarding_pager_screen.dart`
  - `lib/ui/onboarding/get_started_screens.dart`
  - `lib/ui/onboarding/widgets/onboarding_hero.dart`
  - `lib/ui/onboarding/widgets/mock_preview_card.dart`
  - `lib/ui/onboarding/widgets/page_indicator.dart`
  - `lib/ui/onboarding/widgets/get_started_header.dart`

## Media Usage (from `lib/media/svg/...`)
- Splash mark icon: `icons/digital-token.svg` (resolved via `AppIcon`)
- Get Started email icon: `icons/bitcoin-mail.svg`
- Onboarding page 1 hero: Flutter `MockPreviewCard` (`previewVariant: 0`)
- Onboarding page 2 hero illustration: `illustrations/woman-is-looking-at-her-bank-account-statistics.svg`
- Onboarding page 3 hero: Flutter `MockPreviewCard` (`previewVariant: 1`)
- Onboarding page 4 hero illustration: `illustrations/character-coin-is-the-winner.svg`

## Reduced Motion
- Splash fade animation duration becomes `0` when `MediaQuery.disableAnimations == true`.
- Onboarding page advance animation becomes instant when reduced motion is enabled.
- Page indicator animation becomes instant when reduced motion is enabled.
