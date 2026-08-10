create table if not exists public.registered_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 80),
  device_type text not null check (device_type in ('pc', 'mobile')),
  platform text not null default 'Other',
  connected boolean not null default true,
  last_seen_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists registered_devices_user_created_at_idx
on public.registered_devices (user_id, created_at);

alter table public.registered_devices enable row level security;
grant select, insert, update, delete on public.registered_devices to authenticated;

create policy "Users can view their own registered devices"
on public.registered_devices for select to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can register their own devices"
on public.registered_devices for insert to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can update their own registered devices"
on public.registered_devices for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can remove their own registered devices"
on public.registered_devices for delete to authenticated
using ((select auth.uid()) = user_id);
