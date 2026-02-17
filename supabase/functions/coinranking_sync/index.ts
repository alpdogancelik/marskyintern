import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type CoinRankingCoin = {
  uuid: string;
  symbol: string;
  name: string;
  iconUrl?: string | null;
  rank?: number | string;
  price?: string | number;
  marketCap?: string | number;
  "24hVolume"?: string | number;
  change?: string | number;
};

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const COINRANKING_API_KEY = Deno.env.get("COINRANKING_API_KEY") ?? "";

serve(async () => {
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY || !COINRANKING_API_KEY) {
    return new Response(
      JSON.stringify({ error: "Missing required env vars for sync." }),
      { status: 500, headers: { "content-type": "application/json" } },
    );
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
  });

  const coinResponse = await fetch(
    "https://api.coinranking.com/v2/coins?limit=200&offset=0&orderBy=marketCap&orderDirection=desc",
    {
      headers: {
        "x-access-token": COINRANKING_API_KEY,
      },
    },
  );

  if (!coinResponse.ok) {
    return new Response(
      JSON.stringify({ error: "CoinRanking request failed.", status: coinResponse.status }),
      { status: 502, headers: { "content-type": "application/json" } },
    );
  }

  const payload = await coinResponse.json();
  const data = payload?.data;
  const coins = Array.isArray(data?.coins) ? (data.coins as CoinRankingCoin[]) : [];

  if (coins.length === 0) {
    return new Response(
      JSON.stringify({ updated: 0, history_rows: 0, scanned: 0 }),
      { headers: { "content-type": "application/json" } },
    );
  }

  const uuids = coins.map((coin) => coin.uuid).filter(Boolean);

  const { data: existingRows, error: existingError } = await supabase
    .from("coins")
    .select("uuid, symbol, name, icon_url, rank, price, market_cap, volume_24h, change_24h")
    .in("uuid", uuids);

  if (existingError) {
    return new Response(
      JSON.stringify({ error: "Failed to read existing rows." }),
      { status: 500, headers: { "content-type": "application/json" } },
    );
  }

  const existingByUuid = new Map<string, Record<string, unknown>>();
  for (const row of existingRows ?? []) {
    if (typeof row.uuid === "string") {
      existingByUuid.set(row.uuid, row);
    }
  }

  const changedRows: Array<Record<string, unknown>> = [];
  const historyRows: Array<Record<string, unknown>> = [];
  const nowIso = new Date().toISOString();

  for (const coin of coins) {
    if (!coin.uuid) continue;

    const mapped = {
      uuid: coin.uuid,
      symbol: coin.symbol ?? "",
      name: coin.name ?? "",
      icon_url: coin.iconUrl ?? "",
      rank: toInt(coin.rank),
      price: toNum(coin.price),
      market_cap: toNum(coin.marketCap),
      volume_24h: toNum(coin["24hVolume"]),
      change_24h: toNum(coin.change),
      updated_at: nowIso,
    };

    const previous = existingByUuid.get(coin.uuid);
    const shouldWrite = !previous ||
      previous.symbol !== mapped.symbol ||
      previous.name !== mapped.name ||
      previous.icon_url !== mapped.icon_url ||
      Number(previous.rank ?? 0) !== Number(mapped.rank) ||
      Number(previous.price ?? 0) !== Number(mapped.price) ||
      Number(previous.market_cap ?? 0) !== Number(mapped.market_cap) ||
      Number(previous.volume_24h ?? 0) !== Number(mapped.volume_24h) ||
      Number(previous.change_24h ?? 0) !== Number(mapped.change_24h);

    if (!shouldWrite) {
      continue;
    }

    changedRows.push(mapped);
    historyRows.push({
      coin_uuid: mapped.uuid,
      ts: nowIso,
      price: mapped.price,
    });
  }

  if (changedRows.length > 0) {
    const { error: upsertError } = await supabase
      .from("coins")
      .upsert(changedRows, { onConflict: "uuid" });

    if (upsertError) {
      return new Response(
        JSON.stringify({ error: "Failed to upsert coins." }),
        { status: 500, headers: { "content-type": "application/json" } },
      );
    }

    const { error: historyError } = await supabase
      .from("coin_history")
      .upsert(historyRows, { onConflict: "coin_uuid,ts", ignoreDuplicates: true });

    if (historyError) {
      return new Response(
        JSON.stringify({ error: "Failed to write coin history." }),
        { status: 500, headers: { "content-type": "application/json" } },
      );
    }
  }

  return new Response(
    JSON.stringify({
      scanned: coins.length,
      updated: changedRows.length,
      history_rows: historyRows.length,
    }),
    { headers: { "content-type": "application/json" } },
  );
});

function toNum(input: unknown): number {
  if (typeof input === "number") return input;
  if (typeof input === "string") {
    const n = Number(input);
    return Number.isFinite(n) ? n : 0;
  }
  return 0;
}

function toInt(input: unknown): number {
  if (typeof input === "number") return Math.trunc(input);
  if (typeof input === "string") {
    const n = Number(input);
    return Number.isFinite(n) ? Math.trunc(n) : 0;
  }
  return 0;
}
