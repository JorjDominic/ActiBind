create table if not exists public.routines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 100),
  category text not null check (category in (
    'Study', 'Work', 'Focus', 'Sleep', 'Exercise',
    'Entertainment', 'Personal', 'Custom'
  )),
  start_time time not null,
  end_time time not null,
  active_days smallint[] not null default array[1,2,3,4,5,6,7],
  starts_on date not null default current_date,
  ends_on date,
  active boolean not null default true,
  monitor_usage boolean not null default true,
  warn_conflicts boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint routines_valid_time check (end_time > start_time),
  constraint routines_valid_days check (
    cardinality(active_days) between 1 and 7
    and active_days <@ array[1,2,3,4,5,6,7]::smallint[]
  ),
  constraint routines_valid_dates check (ends_on is null or ends_on >= starts_on)
);

create table if not exists public.routine_occurrences (
  id uuid primary key default gen_random_uuid(),
  routine_id uuid not null references public.routines(id) on delete cascade,
  user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  scheduled_date date not null,
  status text not null default 'scheduled'
    check (status in ('scheduled', 'completed', 'skipped')),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (routine_id, scheduled_date)
);

create index if not exists routines_user_active_idx
on public.routines (user_id, active);

create index if not exists routine_occurrences_user_date_idx
on public.routine_occurrences (user_id, scheduled_date);

alter table public.routines enable row level security;
alter table public.routine_occurrences enable row level security;

grant select, insert, update, delete on public.routines to authenticated;
grant select, insert, update, delete on public.routine_occurrences to authenticated;

create policy "Users manage their own routines"
on public.routines for all to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users manage their own routine occurrences"
on public.routine_occurrences for all to authenticated
using (
  (select auth.uid()) = user_id
  and exists (
    select 1 from public.routines
    where routines.id = routine_occurrences.routine_id
      and routines.user_id = (select auth.uid())
  )
)
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1 from public.routines
    where routines.id = routine_occurrences.routine_id
      and routines.user_id = (select auth.uid())
  )
);
