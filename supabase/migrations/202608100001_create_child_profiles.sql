create table if not exists public.child_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 80),
  age_range text not null default '9-12'
    check (age_range in ('Under 6', '6-8', '9-12', '13-15', '16-17')),
  device_name text not null default 'No device linked',
  avatar_color bigint not null default 4284177634,
  connected boolean not null default false,
  restrictions_active boolean not null default false,
  screen_time_minutes integer not null default 0
    check (screen_time_minutes >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists child_profiles_user_created_at_idx
on public.child_profiles (user_id, created_at);

alter table public.child_profiles enable row level security;

grant select, insert, update, delete on public.child_profiles to authenticated;

create policy "Users can view their own child profiles"
on public.child_profiles for select to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can create their own child profiles"
on public.child_profiles for insert to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can update their own child profiles"
on public.child_profiles for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can delete their own child profiles"
on public.child_profiles for delete to authenticated
using ((select auth.uid()) = user_id);
