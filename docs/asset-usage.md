# Asset Usage Map

Source of truth media pack:
- `lib/media/svg/crypto`
- `lib/media/svg/icons`
- `lib/media/svg/illustrations`

Resolver + primitives:
- `AssetResolver` from `lib/media/asset_resolver.dart`
- `CoinLogo` from `lib/core/widgets/coin_logo.dart`
- `AppIcon` from `lib/core/widgets/app_icon.dart`
- `Illustration` and `EmptyState` from `lib/core/widgets`

## Screen Map

### 1) Markets / Coins List (Home)
Screen:
- `lib/features/coins/presentation/home_screen.dart`

Category usage:
- Coin logos: `CoinLogo` in each row (`ListTile.leading`)
- Generic icons: `AppIcon` in AppBar actions (search/filter/sort/logout)
- Illustrations: `EmptyState` illustration for empty/no-results states

Where:
- Header/AppBar: search, filter, sort actions
- List row: coin logo at left, price + change indicator at right
- Empty state: one illustration + single primary CTA

Why:
- Scanability: left-aligned coin logos speed up symbol recognition in dense lists
- Meaning: iconized header actions reduce ambiguity for list controls
- Action clarity: price delta uses text + directional arrow only (no extra decoration)

Do:
- Keep row logo size at 32 for list density
- Use one small arrow icon with percentage text for change
- Keep action icons at 20 in AppBar

Don't:
- Don't render raw asset paths directly in the screen
- Don't mix multiple coin logo shapes or paddings in one list
- Don't stack multiple decorative indicators on price change

### 2) Portfolio (Favorites as Portfolio Equivalent)
Screen:
- `lib/features/favorites/presentation/favorites_screen.dart`

Category usage:
- Coin logos: `CoinLogo` for each holding row
- Generic icons: `AppIcon` for logout action
- Illustrations: `EmptyState` with one portfolio-semantic illustration

Where:
- Header: profile/session action icon
- Holdings list row: logo + coin identity
- Empty portfolio: one illustration + CTA (`Buy first asset`)

Why:
- Scanability: holdings are quickly identified by logo+symbol pairs
- Meaning: portfolio-empty illustration communicates account state
- Action clarity: single CTA provides next step toward first position

Do:
- Keep holdings row logo size at 32
- Use exactly one illustration in empty portfolio
- Keep CTA copy goal-oriented (`Buy first asset`)

Don't:
- Don't use multiple empty-state illustrations
- Don't use ambiguous CTA text for first-time portfolio flow
- Don't use mixed icon sizes within one row

### 3) Swap / Exchange Selector (Coin Detail Equivalent)
Screen:
- `lib/features/coins/presentation/coin_detail_sheet.dart`

Category usage:
- Coin logos: From/To picker entries and selected values
- Generic icons: swap direction, wallet action, payment action
- Illustrations: not used in selector block

Where:
- Swap card header: exchange icon + title
- From/To fields: `CoinLogo` + symbol/name in 56px tap-target selectors
- Action chips: wallet/payment-related actions

Why:
- Scanability: users verify From/To assets by both symbol and logo
- Meaning: swap-direction and wallet/payment icons communicate intent instantly
- Action clarity: 48px+ touch targets reduce miss-taps in transactional UI

Do:
- Keep picker logo size at 24 and tap target minimum at 56 height
- Keep swap direction control at least 48x48
- Use semantic labels on all interactive icon-only controls

Don't:
- Don't hide asset identity behind text-only selectors
- Don't use tiny icon-only buttons in exchange flows
- Don't introduce extra decorative icons that compete with swap direction

## Global Rules

Do:
- Always consume media through `AssetResolver`-based primitives (`CoinLogo`, `AppIcon`, `Illustration`, `EmptyState`)
- Respect normalized logo containers and primitive size scales
- Provide semantic labels for assistive tech

Don't:
- Don't reference `assets/...` or `lib/media/svg/...` paths directly in feature UI
- Don't bypass primitive fallbacks for unknown symbols or missing icons
- Don't mix icon metaphors for the same action across screens
