# Kora (Marsky Challenge)

## English
Kora is a Flutter crypto dashboard built for the Marsky code challenge.

### Setup
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
3. Run:
```bash
flutter run
```
4. Validate:
```bash
flutter analyze
flutter test
```

### Challenge Coverage
- Auth + session guard with Supabase
- Two-tab shell: Home and Favorites
- Paginated/sortable coins
- Favorite persistence with Hive
- Coin detail with history chart
- Error mapping and tests

### Error Handling
- `lib/core/errors/app_exception.dart`
- `lib/core/errors/exception_mapper.dart`
- `lib/core/ui/error_presenter.dart`

### API Notes
- CoinRanking base URL: `https://api.coinranking.com/v2`
- Header: `x-access-token: ${COINRANKING_API_KEY}`
- History endpoint: `/coin/{uuid}/price-history?timePeriod=7d`

### Submission Notes
- Collaborator for evaluation: `okanaktas`

## Turkce
Kora, Marsky kod challenge'i icin gelistirilmis Flutter tabanli bir kripto panelidir.

### Kurulum
1. Bagimliliklari yukleyin:
```bash
flutter pub get
```
2. Proje kokunde `.env` olusturun (veya `.env.example` dosyasini kopyalayin):
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
COINRANKING_API_KEY=your_coinranking_api_key
USE_MOCK_AUTH=false
USE_MOCK_COINS=false
```
3. Uygulamayi calistirin:
```bash
flutter run
```
4. Dogrulayin:
```bash
flutter analyze
flutter test
```

### Challenge Kapsami
- Supabase ile auth + session route guard
- Iki sekmeli kabuk: Home ve Favorites
- Sayfalamali/siralamali coin listesi
- Hive ile favori kaliciligi
- Tarihce chart'li coin detay
- Hata esleme ve testler

### Hata Yonetimi
- `lib/core/errors/app_exception.dart`
- `lib/core/errors/exception_mapper.dart`
- `lib/core/ui/error_presenter.dart`
