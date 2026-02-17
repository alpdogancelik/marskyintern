# Supabase Coin Cache Setup

This folder contains schema and function scaffolding for a Supabase-backed coin cache that mirrors CoinRanking data.

## 1) Apply migration

Migration file:
- `supabase/migrations/0001_init.sql`

Apply via Supabase SQL editor or CLI:

```bash
supabase db push
```

The migration creates:
- `public.coins`
- `public.coin_history`
- `public.favorites`
- `public.portfolio_holdings`
- `public.orders`

RLS is enabled on all tables.

## 2) Realtime for `coins`

Enable realtime replication for the `coins` table:

```sql
alter publication supabase_realtime add table public.coins;
```

You can verify in Supabase Dashboard:
- Database -> Replication -> Realtime -> ensure `public.coins` is enabled.

## 3) Edge Function (recommended)

Function skeleton:
- `supabase/functions/coinranking_sync/index.ts`

Required server env vars (set in Supabase project settings / secrets):
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `COINRANKING_API_KEY`

Important:
- Do **not** commit keys to git.
- Do **not** put service role keys in Flutter client code.

Deploy function:

```bash
supabase functions deploy coinranking_sync
```

## 4) Schedule sync (every 1-5 minutes)

Use Supabase Scheduled Functions (Dashboard) or CLI to call `coinranking_sync` periodically.

Recommended cadence:
- every 1 minute for near-live dashboards
- every 5 minutes for lower write volume

Example HTTP invocation body can be empty (`{}`).

## 5) Flutter runtime switch

Use dart-define / env to enable Supabase cache mode:

- `USE_SUPABASE_COINS_CACHE=true` -> reads coins from Supabase and listens to realtime updates.
- `USE_MOCK_COINS=true` -> uses mock coins repository.
- default -> CoinRanking direct API repository.
- If `USE_MOCK_AUTH=true`, Supabase is not initialized by design; the app falls back to direct CoinRanking repository even when `USE_SUPABASE_COINS_CACHE=true`.

Example:

```bash
flutter run --dart-define=USE_SUPABASE_COINS_CACHE=true
```
