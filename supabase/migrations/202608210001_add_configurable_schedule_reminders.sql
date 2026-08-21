alter table public.activities
add column if not exists reminder_minutes integer not null default 5
check (reminder_minutes in (0, 5, 10, 15, 30, 60));

alter table public.routines
add column if not exists reminder_minutes integer not null default 5
check (reminder_minutes in (0, 5, 10, 15, 30, 60));
