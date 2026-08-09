create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  title text not null,
  content text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.notes enable row level security;

grant select, insert, update, delete
on table public.notes
to authenticated;

create policy "Users can view their own notes"
on public.notes for select to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can create their own notes"
on public.notes for insert to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can update their own notes"
on public.notes for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can delete their own notes"
on public.notes for delete to authenticated
using ((select auth.uid()) = user_id);
