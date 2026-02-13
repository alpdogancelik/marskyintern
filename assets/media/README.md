# Media Asset Standard

This project uses `assets/media/` as the canonical location for runtime media.

## Directories

- `assets/media/illustrations/`
- `assets/media/icons/`
- `assets/media/coin_icons/`

## Naming Rules

- Use `lower_snake_case`.
- Use only letters, numbers, and `_`.
- No spaces.
- No leading numbers.
- Examples:
  - `bitcoin.png`
  - `auth_hero.png`
  - `tab_home_icon.svg`

## Legacy Support (Temporary)

`lib/media/svg/` is deprecated and should not receive new files.
It is still supported at runtime as a fallback path for compatibility during migration.

## Migration Tool

Use:

```bash
dart run tool/normalize_media_assets.dart --dry-run
dart run tool/normalize_media_assets.dart --apply
```

The tool scans `lib/media/svg` PNG files, normalizes names into
`assets/media/coin_icons`, and writes a mapping file at:
`assets/media/coin_icons/_mapping.json`.
