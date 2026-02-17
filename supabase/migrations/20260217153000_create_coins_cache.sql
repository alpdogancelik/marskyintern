-- Coins cache table alignment for CoinRanking + Realtime.
-- Idempotent migration: safe to run multiple times.

create table if not exists public.coins (
  coin_uuid text primary key,
  symbol text not null,
  name text not null,
  icon_url text,
  rank integer,
  price numeric(38,18),
  market_cap numeric(38,0),
  volume_24h numeric(38,0),
  change_24h numeric(10,4),
  btc_price numeric(38,18),
  listed_at timestamptz,
  raw jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Compatibility for existing repo schema/function usage:
-- legacy code references `uuid`, newer cache shape uses `coin_uuid`.
alter table public.coins add column if not exists uuid text;
alter table public.coins add column if not exists coin_uuid text;
alter table public.coins add column if not exists btc_price numeric(38,18);
alter table public.coins add column if not exists listed_at timestamptz;
alter table public.coins add column if not exists raw jsonb;
alter table public.coins add column if not exists created_at timestamptz;

update public.coins
set coin_uuid = uuid
where coin_uuid is null
  and uuid is not null;

update public.coins
set uuid = coin_uuid
where uuid is null
  and coin_uuid is not null;

alter table public.coins alter column price type numeric(38,18) using price::numeric;
alter table public.coins alter column market_cap type numeric(38,0) using market_cap::numeric;
alter table public.coins alter column volume_24h type numeric(38,0) using volume_24h::numeric;
alter table public.coins alter column change_24h type numeric(10,4) using change_24h::numeric;

update public.coins set raw = '{}'::jsonb where raw is null;
update public.coins set created_at = now() where created_at is null;
update public.coins set updated_at = now() where updated_at is null;

alter table public.coins alter column raw set default '{}'::jsonb;
alter table public.coins alter column raw set not null;
alter table public.coins alter column created_at set default now();
alter table public.coins alter column created_at set not null;
alter table public.coins alter column updated_at set default now();
alter table public.coins alter column updated_at set not null;

create unique index if not exists coins_coin_uuid_key on public.coins (coin_uuid);
create unique index if not exists coins_uuid_key on public.coins (uuid);
create index if not exists coins_rank_idx on public.coins (rank);
create index if not exists coins_price_idx on public.coins (price);
create index if not exists coins_market_cap_idx on public.coins (market_cap);
create index if not exists coins_volume_24h_idx on public.coins (volume_24h);
create index if not exists coins_change_24h_idx on public.coins (change_24h);
create index if not exists coins_listed_at_idx on public.coins (listed_at);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  if new.coin_uuid is null then
    new.coin_uuid = new.uuid;
  end if;
  if new.uuid is null then
    new.uuid = new.coin_uuid;
  end if;
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_coins_updated_at on public.coins;
drop trigger if exists set_updated_at_coins on public.coins;
create trigger set_updated_at_coins
before insert or update on public.coins
for each row execute function public.set_updated_at();

alter table public.coins enable row level security;

-- Keep coins read-only from clients (sync is handled by Edge Function/service role).
do $$
declare
  policy_row record;
begin
  for policy_row in
    select policyname
    from pg_policies
    where schemaname = 'public'
      and tablename = 'coins'
      and cmd <> 'SELECT'
  loop
    execute format('drop policy if exists %I on public.coins', policy_row.policyname);
  end loop;
end $$;

drop policy if exists "Coins are readable by everyone" on public.coins;
drop policy if exists coins_public_read on public.coins;
create policy "Coins are readable by everyone"
on public.coins
for select
to anon, authenticated
using (true);

alter table public.coins replica identity full;

do $$
begin
  if exists (
    select 1
    from pg_publication
    where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'coins'
  ) then
    alter publication supabase_realtime add table public.coins;
  end if;
end $$;

-- Verification:
-- select count(*) from public.coins;
-- select * from pg_publication_tables
-- where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'coins';
