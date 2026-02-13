# Media Usage

## Coin Logos By Symbol

Load the resolver once, then request coin assets by symbol or alias:

```dart
final resolver = await AssetResolver.load();

final btcLogo = resolver.resolveCoin('BTC');
final usdtLogo = resolver.resolveCoin('Tether USDt'); // alias -> USDT
final unknownLogo = resolver.resolveCoin('unknown'); // falls back to generic coin
```

Notes:
- Symbols are resolved case-insensitively (`btc`, `BTC`, `Btc` all work).
- Name aliases come from `lib/media/assets-manifest.json` (`aliases` section).
- Fallbacks are generic assets when a key is missing (`coin`/`icon` fallback paths).
