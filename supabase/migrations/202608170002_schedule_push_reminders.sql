create extension if not exists pg_cron with schema pg_catalog;
create extension if not exists pg_net with schema extensions;
create extension if not exists supabase_vault with schema vault;

do $$
begin
  if not exists (
    select 1 from vault.secrets where name = 'reminder_cron_secret'
  ) then
    perform vault.create_secret(
      encode(extensions.gen_random_bytes(32), 'hex'),
      'reminder_cron_secret',
      'Authenticates the private ActiBind reminder cron job'
    );
  end if;
end;
$$;

create or replace function public.verify_reminder_cron_secret(candidate text)
returns boolean
language sql
stable
security definer
set search_path = public, vault
as $$
  select candidate <> '' and candidate = (
    select decrypted_secret
    from vault.decrypted_secrets
    where name = 'reminder_cron_secret'
    limit 1
  );
$$;

revoke all on function public.verify_reminder_cron_secret(text) from public, anon, authenticated;
grant execute on function public.verify_reminder_cron_secret(text) to service_role;

do $$
declare
  existing_job bigint;
begin
  select jobid into existing_job
  from cron.job
  where jobname = 'send-actibind-due-reminders';
  if existing_job is not null then
    perform cron.unschedule(existing_job);
  end if;

  perform cron.schedule(
    'send-actibind-due-reminders',
    '* * * * *',
    $cron$
      select net.http_post(
        url := 'https://smlgnwnbuhruprlynfuw.supabase.co/functions/v1/send-due-reminders',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'x-cron-secret', (
            select decrypted_secret
            from vault.decrypted_secrets
            where name = 'reminder_cron_secret'
            limit 1
          )
        ),
        body := '{"source":"supabase-cron"}'::jsonb,
        timeout_milliseconds := 15000
      );
    $cron$
  );
end;
$$;
