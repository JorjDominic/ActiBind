create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 100),
  category text not null default 'Focus',
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  repeat text not null default 'Never',
  monitor_usage boolean not null default true,
  warn_conflicts boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint activities_valid_time check (ends_at > starts_at)
);

create index if not exists activities_user_starts_at_idx
on public.activities (user_id, starts_at);

alter table public.activities enable row level security;

grant select, insert, update, delete on public.activities to authenticated;

create policy "Users can view their own activities"
on public.activities for select to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can create their own activities"
on public.activities for insert to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can update their own activities"
on public.activities for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can delete their own activities"
on public.activities for delete to authenticated
using ((select auth.uid()) = user_id);
