alter table public.activities
  add constraint activities_valid_category check (
    category in (
      'Study', 'Work', 'Focus', 'Sleep', 'Exercise',
      'Entertainment', 'Personal', 'Custom'
    )
  ),
  add constraint activities_valid_repeat check (
    repeat in ('Never', 'Daily', 'Weekdays', 'Weekends')
  );
