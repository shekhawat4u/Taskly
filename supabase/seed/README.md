# Seed data (development only)

Create these Auth users in the Supabase dashboard (Email provider, confirm emails):

| Email | Suggested password | Role |
| --- | --- | --- |
| rahul@taskly.dev | ChangeMe!Rahul1 | Founder |
| priya@taskly.dev | ChangeMe!Priya1 | Admin |
| aman@taskly.dev | ChangeMe!Aman1 | Intern |
| riya@taskly.dev | ChangeMe!Riya1 | Intern |
| karan@taskly.dev | ChangeMe!Karan1 | Employee |

Then run `supabase/seed/seed.sql` in the SQL editor.

The Flutter UI never ships these users as hardcoded data. They exist only after you seed a development project.
