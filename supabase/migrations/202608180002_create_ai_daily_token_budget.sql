create table if not exists public.ai_daily_token_usage (
  usage_date date primary key,
  tokens_used bigint not null default 0 check (tokens_used >= 0),
  updated_at timestamptz not null default now()
);

alter table public.ai_daily_token_usage enable row level security;
revoke all on public.ai_daily_token_usage from public, anon, authenticated;

create or replace function public.reserve_ai_daily_tokens(
  requested_date date,
  requested_tokens bigint,
  token_limit bigint
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
begin
  if requested_tokens <= 0 or token_limit <= 0 or requested_tokens > token_limit then
    return false;
  end if;

  insert into public.ai_daily_token_usage (usage_date, tokens_used)
  values (requested_date, requested_tokens)
  on conflict (usage_date) do update
    set tokens_used = public.ai_daily_token_usage.tokens_used + excluded.tokens_used,
        updated_at = now()
    where public.ai_daily_token_usage.tokens_used + excluded.tokens_used <= token_limit;

  return found;
end;
$$;

create or replace function public.settle_ai_daily_tokens(
  requested_date date,
  reserved_tokens bigint,
  actual_tokens bigint
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if reserved_tokens < 0 or actual_tokens < 0 then
    raise exception 'Token counts cannot be negative';
  end if;

  update public.ai_daily_token_usage
  set tokens_used = greatest(0, tokens_used - reserved_tokens + actual_tokens),
      updated_at = now()
  where usage_date = requested_date;
end;
$$;

revoke all on function public.reserve_ai_daily_tokens(date, bigint, bigint)
from public, anon, authenticated;
revoke all on function public.settle_ai_daily_tokens(date, bigint, bigint)
from public, anon, authenticated;
grant execute on function public.reserve_ai_daily_tokens(date, bigint, bigint)
to service_role;
grant execute on function public.settle_ai_daily_tokens(date, bigint, bigint)
to service_role;
