create or replace function public.read_ai_daily_tokens(requested_date date)
returns bigint
language sql
security definer
stable
set search_path = ''
as $$
  select coalesce(
    (select tokens_used
     from public.ai_daily_token_usage
     where usage_date = requested_date),
    0
  );
$$;

revoke all on function public.read_ai_daily_tokens(date)
from public, anon, authenticated;
grant execute on function public.read_ai_daily_tokens(date) to service_role;
