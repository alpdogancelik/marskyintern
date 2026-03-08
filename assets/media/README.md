# Media Asset Standard

## English
This project uses `assets/media/` as the canonical location for runtime media.

### Directories
- `assets/media/illustrations/`
- `assets/media/icons/`
- `assets/media/coin_icons/`

### Naming Rules
- Use `lower_snake_case`.
- Use only letters, numbers, and `_`.
- No spaces.
- No leading numbers.
- Examples:
  - `bitcoin.png`
  - `auth_hero.png`
  - `tab_home_icon.svg`

### Legacy Support (Temporary)
`lib/media/svg/` is deprecated and should not receive new files.
It is still supported at runtime as a fallback path during migration.

### Migration Tool
```bash
dart run tool/normalize_media_assets.dart --dry-run
dart run tool/normalize_media_assets.dart --apply
```
The tool scans `lib/media/svg` PNG files, normalizes names into
`assets/media/coin_icons`, and writes:
`assets/media/coin_icons/_mapping.json`.

## Turkce
Bu projede calisma zamani medya dosyalari icin standart dizin `assets/media/` klasorudur.

### Dizinler
- `assets/media/illustrations/`
- `assets/media/icons/`
- `assets/media/coin_icons/`

### Isimlendirme Kurallari
- `lower_snake_case` kullanin.
- Sadece harf, rakam ve `_` kullanin.
- Bosluk kullanmayin.
- Rakamla baslamayin.

### Gecis Donemi Destegi
`lib/media/svg/` artik yeni dosya almamali (deprecated).
Yine de gecis sureci icin runtime fallback olarak desteklenir.

### Migration Araci
```bash
dart run tool/normalize_media_assets.dart --dry-run
dart run tool/normalize_media_assets.dart --apply
```
Arac `lib/media/svg` altindaki PNG dosyalarini tarar, normalize eder,
`assets/media/coin_icons` altina tasir ve su dosyayi yazar:
`assets/media/coin_icons/_mapping.json`.
