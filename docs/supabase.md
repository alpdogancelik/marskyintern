# Supabase Setup

This app supports two auth modes:

- Supabase auth (default)
- mock auth (`--dart-define=USE_MOCK_AUTH=true`)
- Supabase coin cache (`--dart-define=USE_SUPABASE_COINS_CACHE=true`)

## Environment variables

Set these in `.env` (project root):

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-or-publishable-key
COINRANKING_API_KEY=your-coinranking-key
```

Notes:

- `SUPABASE_URL` and `SUPABASE_ANON_KEY` are required when `USE_MOCK_AUTH=false`.
- Do not commit real keys to git.
- `USE_SUPABASE_COINS_CACHE=true` enables reading the coin list from Supabase cache + Realtime.
- If `USE_MOCK_AUTH=true`, Supabase is intentionally not initialized; coin cache mode will fall back to direct CoinRanking repository.

## App startup behavior

- `USE_MOCK_AUTH=true`: Supabase initialization is skipped and `MockAuthRepository` is used.
- `USE_MOCK_AUTH=false` (default): app calls `initSupabase()` and uses `SupabaseAuthRepository`.

## Apply database migration

Migration file:

- `supabase/migrations/0001_init.sql`

### Option 1: Supabase SQL Editor

1. Open your Supabase project dashboard.
2. Go to SQL Editor.
3. Paste contents of `supabase/migrations/0001_init.sql`.
4. Run the script.

### Option 2: Supabase CLI

```bash
supabase db push
```

or run migration SQL directly:

```bash
supabase migration up
```

## What the migration creates

- `profiles` table (`auth.users` FK)
- `favorites` table
- `portfolio_positions` table
- `orders` table
- trigger to auto-create `profiles` row on signup (`auth.users` insert)
- RLS policies on all tables

## RLS behavior

Row Level Security is enabled for all app tables:

- `profiles`: users can only select/update rows where `id = auth.uid()`
- `favorites`, `portfolio_positions`, `orders`: users can only select/insert/update/delete rows where `user_id = auth.uid()`

This means client-side anon/authenticated keys can only access the signed-in user's rows.
