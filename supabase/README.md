# Supabase Coin Cache Setup

## English
This folder contains schema and function scaffolding for a Supabase-backed coin cache that mirrors CoinRanking data.

### 1) Apply migrations
Migration files:
- `supabase/migrations/0001_init.sql`
- `supabase/migrations/20260217153000_create_coins_cache.sql`

Run with SQL editor or CLI:
```bash
supabase db push
```

Creates:
- `public.coins`
- `public.coin_history`
- `public.favorites`
- `public.portfolio_holdings`
- `public.orders`

RLS is enabled on all tables.

### 2) Realtime for `coins`
```sql
alter publication supabase_realtime add table public.coins;
```
Verify in Dashboard:
- Database -> Replication -> Realtime -> `public.coins`

### 3) Edge Function (recommended)
- `supabase/functions/coinranking_sync/index.ts`

Required server env vars:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `COINRANKING_API_KEY`

Security:
- Never commit keys to git.
- Never use service role key in Flutter client code.

Deploy:
```bash
supabase functions deploy coinranking_sync
```

### 4) Schedule sync (1-5 min)
Use Scheduled Functions to call `coinranking_sync` every 1-5 minutes.

### 5) Flutter runtime switch
- `USE_SUPABASE_COINS_CACHE=true`: read from Supabase + realtime
- `USE_MOCK_COINS=true`: use mock coins
- default: direct CoinRanking API
- `USE_MOCK_AUTH=true`: Supabase init is skipped

## Turkce
Bu klasor, CoinRanking verisini Supabase uzerinde cachelemek icin schema ve function iskeletini icerir.

### 1) Migrationlari uygula
Migration dosyalari:
- `supabase/migrations/0001_init.sql`
- `supabase/migrations/20260217153000_create_coins_cache.sql`

SQL Editor veya CLI ile calistir:
```bash
supabase db push
```

Olusan tablolar:
- `public.coins`
- `public.coin_history`
- `public.favorites`
- `public.portfolio_holdings`
- `public.orders`

Tum tablolarda RLS aciktir.

### 2) `coins` icin Realtime
```sql
alter publication supabase_realtime add table public.coins;
```
Dashboard kontrolu:
- Database -> Replication -> Realtime -> `public.coins`

### 3) Edge Function (onerilen)
- `supabase/functions/coinranking_sync/index.ts`

Sunucu ortam degiskenleri:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `COINRANKING_API_KEY`

Guvenlik:
- Anahtarlari git'e commit etmeyin.
- Service role key'i Flutter client'ta kullanmayin.

Deploy:
```bash
supabase functions deploy coinranking_sync
```

### 4) Senkronizasyon zamanlama (1-5 dk)
`coinranking_sync` fonksiyonunu 1-5 dakikada bir calistiracak sekilde schedule edin.

### 5) Flutter runtime switch
- `USE_SUPABASE_COINS_CACHE=true`: Supabase + realtime
- `USE_MOCK_COINS=true`: mock coin verisi
- varsayilan: dogrudan CoinRanking API
- `USE_MOCK_AUTH=true`: Supabase init edilmez
