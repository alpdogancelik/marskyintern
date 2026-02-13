import 'dart:convert';

import 'package:flutter/services.dart';

class AssetResolver {
  AssetResolver._({
    required Map<String, String> coins,
    required Map<String, String> icons,
    required Map<String, String> illustrations,
    required Map<String, String> aliases,
  })  : _coins = Map<String, String>.unmodifiable(coins),
        _icons = Map<String, String>.unmodifiable(icons),
        _illustrations = Map<String, String>.unmodifiable(illustrations),
        _aliases = Map<String, String>.unmodifiable(aliases),
        _normalizedAliases = Map<String, String>.unmodifiable(
          aliases.map(
            (key, value) => MapEntry(
              _normalizeAliasKey(key),
              value.toUpperCase(),
            ),
          ),
        );

  static const String manifestAssetPath = 'lib/media/assets-manifest.json';
  static const String defaultCoinFallback = 'lib/media/svg/icons/coin.svg';
  static const String defaultIconFallback = 'lib/media/svg/icons/icon.svg';
  static const String defaultIllustrationFallback =
      'lib/media/svg/illustrations/managing-money.svg';

  static AssetResolver? _cached;
  static AssetResolver? get cached => _cached;

  final Map<String, String> _coins;
  final Map<String, String> _icons;
  final Map<String, String> _illustrations;
  final Map<String, String> _aliases;
  final Map<String, String> _normalizedAliases;

  Map<String, String> get coins => _coins;
  Map<String, String> get icons => _icons;
  Map<String, String> get illustrations => _illustrations;
  Map<String, String> get aliases => _aliases;

  static Future<AssetResolver> load({bool forceReload = false}) async {
    if (!forceReload && _cached != null) {
      return _cached!;
    }

    final raw = await rootBundle.loadString(manifestAssetPath);
    final normalizedRaw = raw.startsWith('\uFEFF') ? raw.substring(1) : raw;
    final decoded = jsonDecode(normalizedRaw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid media manifest format.');
    }

    final resolver = AssetResolver._(
      coins: _asStringMap(decoded['coins']),
      icons: _asStringMap(decoded['icons']),
      illustrations: _asStringMap(decoded['illustrations']),
      aliases: _asStringMap(decoded['aliases']),
    );
    _cached = resolver;
    return resolver;
  }

  String resolveCoin(String symbolOrName, {String? fallback}) {
    final normalizedSymbol = _normalizeSymbol(symbolOrName);
    final coinFromSymbol = _coins[normalizedSymbol];
    if (coinFromSymbol != null) {
      return coinFromSymbol;
    }

    final aliasKey = _normalizeAliasKey(symbolOrName);
    final aliasSymbol = _normalizedAliases[aliasKey];
    if (aliasSymbol != null) {
      final coinFromAlias = _coins[aliasSymbol];
      if (coinFromAlias != null) {
        return coinFromAlias;
      }
    }

    return fallback ?? _coinFallback;
  }

  String resolveCoinVariant(
    String symbolOrName, {
    int variant = 1,
    String? fallback,
  }) {
    final primary = resolveCoin(symbolOrName, fallback: fallback);
    if (variant <= 1) {
      return primary;
    }

    final separator = primary.lastIndexOf('.');
    if (separator <= 0 || separator == primary.length - 1) {
      return '$primary-v$variant';
    }

    final stem = primary.substring(0, separator);
    final ext = primary.substring(separator);
    return '$stem-v$variant$ext';
  }

  String resolveIcon(String iconKey, {String? fallback}) {
    final slug = _slugify(iconKey);
    final icon = _icons[slug];
    if (icon != null) {
      return icon;
    }
    return fallback ?? _iconFallback;
  }

  String resolveIllustration(String illustrationKey, {String? fallback}) {
    final slug = _slugify(illustrationKey);
    final illustration = _illustrations[slug];
    if (illustration != null) {
      return illustration;
    }
    return fallback ?? _illustrationFallback;
  }

  String? resolveSymbolAlias(String symbolOrName) {
    final normalizedSymbol = _normalizeSymbol(symbolOrName);
    if (_coins.containsKey(normalizedSymbol)) {
      return normalizedSymbol;
    }
    return _normalizedAliases[_normalizeAliasKey(symbolOrName)];
  }

  String get _coinFallback => _icons['coin'] ?? defaultCoinFallback;

  String get _iconFallback =>
      _icons['icon'] ?? _icons['wallet'] ?? defaultIconFallback;

  String get _illustrationFallback {
    if (_illustrations.containsKey('managing-money')) {
      return _illustrations['managing-money']!;
    }
    if (_illustrations.isNotEmpty) {
      return _illustrations.values.first;
    }
    return defaultIllustrationFallback;
  }

  String icon(String name, {String? fallback}) {
    return resolveIcon(name, fallback: fallback);
  }

  String illustration(String name, {String? fallback}) {
    return resolveIllustration(name, fallback: fallback);
  }

  static Map<String, String> _asStringMap(Object? value) {
    if (value is! Map) {
      return <String, String>{};
    }
    final output = <String, String>{};
    for (final entry in value.entries) {
      final key = entry.key;
      final item = entry.value;
      if (key is String && item is String) {
        output[key] = item;
      }
    }
    return output;
  }

  static String _normalizeSymbol(String input) {
    return input.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  static String _normalizeAliasKey(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  static String _slugify(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}

String icon(String name, {String? fallback}) {
  final resolver = AssetResolver.cached;
  if (resolver != null) {
    return resolver.icon(name, fallback: fallback);
  }
  return fallback ?? AssetResolver.defaultIconFallback;
}

String illustration(String name, {String? fallback}) {
  final resolver = AssetResolver.cached;
  if (resolver != null) {
    return resolver.illustration(name, fallback: fallback);
  }
  return fallback ?? AssetResolver.defaultIllustrationFallback;
}
