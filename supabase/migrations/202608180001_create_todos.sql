create table if not exists public.todos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 120),
  notes text check (notes is null or char_length(notes) <= 1000),
  priority text not null default 'medium'
    check (priority in ('low', 'medium', 'high')),
  due_date date,
  completed boolean not null default false,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint todos_completion_time check (
    (completed and completed_at is not null)
    or (not completed and completed_at is null)
  )
);

create index if not exists todos_user_status_due_idx
on public.todos (user_id, completed, due_date);

alter table public.todos enable row level security;
grant select, insert, update, delete on public.todos to authenticated;

create policy "Users can view their own todos"
on public.todos for select to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can create their own todos"
on public.todos for insert to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can update their own todos"
on public.todos for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can delete their own todos"
on public.todos for delete to authenticated
using ((select auth.uid()) = user_id);
