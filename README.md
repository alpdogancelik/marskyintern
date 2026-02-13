# Kora (Marsky Challenge)

Kora is a Flutter crypto dashboard built for the Marsky code challenge.

## Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Create `.env` in the project root (or copy from `.env.example`):
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
COINRANKING_API_KEY=your_coinranking_api_key
USE_MOCK_AUTH=false
USE_MOCK_COINS=false
```

3. Run the app:
```bash
flutter run
```

4. Validate:
```bash
flutter analyze
flutter test
```

## PDF Checklist Mapping

### 1) Authentication and Session Management
- [x] Registration and login with Supabase
- [x] Secure session-based route guarding
- [x] Permanent logout icon on Home/Favorites
- [x] Logout confirmation dialog and redirect to login

### 2) Main Navigation
- [x] Two-tab app shell: Home and Favorites

### 3) Home Requirements
- [x] Paginated coin list for smooth loading
- [x] Favorite icon per coin (add/remove)
- [x] Sort options: `price`, `marketCap`, `24hVolume`, `change`, `listedAt`

### 4) Favorites Requirements
- [x] Favorites tab lists only favorited coins
- [x] Tap coin opens detail via iOS-style modal bottom sheet

### 5) Detail Requirements
- [x] Shows name, rank, symbol, current price, change rate, high/low
- [x] Line chart for historical values (`fl_chart`)

### 6) Technical Expectations
- [x] Riverpod-based state management
- [x] Hive local persistence for favorites (`favorites_{userId}`)
- [x] Global friendly error mapping and presentation for API/network failures
- [x] Clean architecture folder organization under `lib/core` and `lib/features/*`
- [x] Unit test included (`test/core/errors/exception_mapper_test.dart`)

## Error Handling

Standardized exceptions live in:
- `lib/core/errors/app_exception.dart`
- `lib/core/errors/exception_mapper.dart`

Shared UI presenter lives in:
- `lib/core/ui/error_presenter.dart`

These are used across auth, home, favorites, and detail flows for user-friendly SnackBars/dialogs.

## API Notes

- CoinRanking base URL: `https://api.coinranking.com/v2`
- Header: `x-access-token: ${COINRANKING_API_KEY}`
- History endpoint: `/coin/{uuid}/price-history?timePeriod=7d`

## Submission Notes

- Add collaborator for evaluation: `okanaktas`

## WIP Commit Guidance

Use regular incremental commits, for example:
- `WIP: setup brand system and app theme`
- `WIP: implement supabase auth and guarded routing`
- `WIP: add home pagination and favorites toggles`
- `WIP: add favorites hive persistence with user scoping`
- `WIP: implement coin detail sheet and history chart`
- `WIP: finalize global error handling and docs`
