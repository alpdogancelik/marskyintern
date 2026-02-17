import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/supabase/supabase_config.dart';
import 'coinranking_api.dart';
import 'coins_remote_data_source.dart';
import '../domain/coins_repository.dart';
import '../domain/entities/coin.dart';

final supabaseCoinsRepositoryProvider =
    Provider<SupabaseCoinsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final remoteDataSource = ref.watch(coinsRemoteDataSourceProvider);
  return SupabaseCoinsRepository(
    client,
    fallbackRemoteDataSource: remoteDataSource,
  );
});

class SupabaseCoinsRepository implements CoinsRepository {
  SupabaseCoinsRepository(
    this._client, {
    this.fallbackRemoteDataSource,
  });

  final SupabaseClient _client;
  final CoinsRemoteDataSource? fallbackRemoteDataSource;
  static const int _fallbackLimit = 100;

  Stream<List<Coin>> watchCoins() {
    return _client
        .from('coins')
        .stream(primaryKey: const ['uuid'])
        .order('rank', ascending: true)
        .map((rows) => rows.map(_mapCoinRow).toList(growable: false));
  }

  Future<List<Coin>> fetchCoinsOnce() async {
    final response = await _client
        .from('coins')
        .select()
        .order('rank', ascending: true)
        .limit(_fallbackLimit);
    final rows = _asRowList(response);
    if (rows.isEmpty && fallbackRemoteDataSource != null) {
      final fallback = await fallbackRemoteDataSource!.listCoins(
        limit: _fallbackLimit,
        offset: 0,
        orderBy: CoinOrderBy.marketCap,
        orderDirection: CoinOrderDirection.desc,
      );
      return fallback.map((dto) => dto.toEntity()).toList(growable: false);
    }
    return rows.map(_mapCoinRow).toList(growable: false);
  }

  @override
  Future<List<Coin>> getCoins({
    required int limit,
    required int offset,
    String? orderBy,
    String? orderDirection,
  }) async {
    final ascending = (orderDirection ?? 'desc').toLowerCase() == 'asc';
    final column = _columnForOrderBy(orderBy);
    final response = await _client
        .from('coins')
        .select()
        .order(column, ascending: ascending)
        .range(offset, offset + limit - 1);
    final rows = _asRowList(response);
    if (rows.isEmpty && fallbackRemoteDataSource != null) {
      final fallback = await fallbackRemoteDataSource!.listCoins(
        limit: limit,
        offset: offset,
        orderBy: CoinOrderBy.fromValue(orderBy),
        orderDirection: CoinOrderDirection.fromValue(orderDirection),
      );
      return fallback.map((dto) => dto.toEntity()).toList(growable: false);
    }
    return rows.map(_mapCoinRow).toList(growable: false);
  }

  @override
  Future<Coin> getCoinByUuid(String uuid) async {
    final response =
        await _client.from('coins').select().eq('uuid', uuid).maybeSingle();
    final row = _asRow(response);
    if (row == null) {
      if (fallbackRemoteDataSource != null) {
        final dto = await fallbackRemoteDataSource!.getCoinByUuid(uuid);
        return dto.toEntity();
      }
      throw NotFoundException('Coin with uuid "$uuid" was not found.');
    }
    return _mapCoinRow(row);
  }

  String _columnForOrderBy(String? orderBy) {
    return switch (orderBy) {
      'price' => 'price',
      'marketCap' => 'market_cap',
      '24hVolume' => 'volume_24h',
      'change' => 'change_24h',
      'listedAt' => 'updated_at',
      _ => 'market_cap',
    };
  }

  Coin _mapCoinRow(Map<String, dynamic> row) {
    return Coin(
      uuid: _asString(row['uuid']),
      symbol: _asString(row['symbol']),
      name: _asString(row['name']),
      iconUrl: _asString(row['icon_url']),
      rank: _asInt(row['rank']),
      price: _asDouble(row['price']),
      marketCap: _asDouble(row['market_cap']),
      volume24h: _asDouble(row['volume_24h']),
      change: _asDouble(row['change_24h']),
      listedAt: _asDateTime(row['updated_at']),
    );
  }

  List<Map<String, dynamic>> _asRowList(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _asRow(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return null;
  }

  String _asString(Object? value) => value?.toString() ?? '';

  int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime? _asDateTime(Object? value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
