---
title: "Upgrading PostgreSQL 13 to 15"
author: Justus Wilhelm Perlwitz
---

Here are some notes on how I upgraded PostgreSQL 13 to 15 on the Heroku
instance running the [Projectify
backend](https://github.com/jwp-consulting/projectify-backend). Previously
Projectify would run on [PostgreSQL
13.13](https://www.postgresql.org/docs/release/13.13/). While PostgreSQL 13 is
still actively supported by the PostgreSQL maintainers at the time of writing,
Debian 12 supports PostgreSQL 15. The current version of [PostgreSQL is
16.1](https://www.postgresql.org/docs/16/index.html).

[Debian 12 came out in June 2023](https://www.debian.org/News/2023/20230610).
Even after upgrading, I was still using PostgreSQL 13 to develop locally for a
while. Between having a containerized continuous integration, and using Nix
flakes to develop locally, I have been wanting to use newer PostgreSQL for a
while. Now, with Debian 12, PostgreSQL 15 is the officially supported version,
and all runtime environments can finally catch up.

# The upgrade procedure

Upgrading PostgreSQL versions is [effortless and highly
automatable](https://www.postgresql.org/docs/15/upgrading.html). In the case of
a managed PostgreSQL instance on Heroku, the process roughly consists of the
following steps:

1. Spin up a follower instance to the existing PostgreSQL 13 instance
2. Wait for the follower to catch up
3. Enter maintenance mode in the application
4. Upgrade the follower to PostgreSQL 15
5. Switch the follower to be the new primary database
6. Leave maintenance mode
7. Clean up and remove the old database instance

This is [well documented in the Heroku Dev
Center](https://devcenter.heroku.com/articles/upgrading-heroku-postgres-databases)
and I wanted to add another data point to successful runs.

## Create a follower instance

First, I dial into a nix shell with Heroku using the following invocation:

```bash
nix-shell -p heroku
```

Which promptly downloads and launches a bash session:

```
this path will be fetched (8.09 MiB download, 87.36 MiB unpacked):
  /nix/store/vwq72x1pw7ks1w3xfa1wm2l0dnirlhwp-heroku-7.66.4
copying path '/nix/store/vwq72x1pw7ks1w3xfa1wm2l0dnirlhwp-heroku-7.66.4' from 'https://cache.nixos.org'...
[nix-shell:~/projects/projectify/projectify-backend]$
```

I log in using `heroku login`, and proceed to create the follower database
using the following, where `MYAPP` stands for the name of the Projectify
backend application:

```bash
heroku addons:create heroku-postgresql:standard-0 --follow DATABASE --app MYAPP
```

Upon which, I see the following output:

```
Creating heroku-postgresql:standard-0 on ⬢ MYAPP... $50/month
 ▸    Release command executing: config vars set by this add-on will not be available until the command succeeds. Use `heroku releases:output` to view the log.
The database should be available in 3-5 minutes.
Use `heroku pg:wait` to track status.
postgresql-XXXXXXXXX-11111 is being created in the background. The app will restart when complete...
Use heroku addons:info postgresql-XXXXXXXXX-11111 to check creation progress
Use heroku addons:docs heroku-postgresql to view documentation
```

## Catching up with the primary

Adding the follower database, we are instructed to wait using the `pg:wait`
command. We run `heroku pg:wait --app MYAPP`, and a few minutes later, we see
the following output:

```
Waiting for database postgresql-XXXXXXXXX-11111... available
```

We want to review the state of all provisioned databases and run `heroku
pg:info --app MYAPP`. Note that `DATABASE_URL` is the previous database that we
have created, and `HEROKU_POSTGRESQL_NAVY` is the new database. The PG versions
match, and we will upgrade the follower to PostgreSQL 15 in the next step.

```
=== DATABASE_URL
Plan:                  Standard 0
Status:                Available
[...]
PG Version:            13.13
[...]
Created:               2022-06-30 07:28
[...]

=== HEROKU_POSTGRESQL_NAVY_URL
Plan:                  Standard 0
Status:                Available
[...]
PG Version:            13.13
[...]
Created:               2024-01-31 02:28
[...]
Following:             DATABASE
Behind By:             0 commits
[...]
```

We see for `HEROKU_POSTGRESQL_NAVY` that it follows `DATABASE` (our
primary), and has caught up with commit. (`0 commits` in the output)

## Entering maintenance mode

To prevent writes on the primary database and eventually swap it out with the
upgraded follower, we enter maintenance mode using `heroku maintenance:on --app
MYAPP`:

```
Enabling maintenance mode for ⬢ MYAPP... done
```

We try to connect to the Projectify API at `https://api.projectifyapp.com/` and
see that it indeed presents a Heroku maintenance screen.

## Upgrading the follower

We are now ready to upgrade the follower database (`NAVY`) to use PostgreSQL 15.
Following the [instructions from the Heroku documentation](https://devcenter.heroku.com/articles/upgrading-heroku-postgres-databases#3-upgrade-the-follower-database), we run the following command:

```
heroku pg:upgrade HEROKU_POSTGRESQL_NAVY_URL --app MYAPP
```

The upgrade process requires you to confirm the name of the app in order to go
through with the upgrade:

```
 ▸    WARNING: Destructive action
 ▸    postgresql-XXXXXXXXX-11111 will be upgraded to a newer PostgreSQL version, stop following DATABASE, and become writable.
 ▸
 ▸    This cannot be undone.
 ▸    To proceed, type MYAPP or re-run this command with --confirm MYAPP

> MYAPP
Starting upgrade of postgresql-XXXXXXXXX-11111... heroku pg:wait to track status
```

We wait for the upgrade to finish as suggested above using `heroku pg:wait --app MYAPP`:

```
Waiting for database postgresql-XXXXXXXXX-11111... performing final cleanup steps after upgrade
```

The upgrade finished without any complications and we are ready to switch the
follower instance to be the primary `DATABASE_URL`.

## Follower to primary switch-over

As instructed in the Heroku upgrade documentation, we run

```bash
heroku pg:promote HEROKU_POSTGRESQL_NAVY_URL --app MYAPP
```

And we see the following output:

```
Ensuring an alternate alias for existing DATABASE_URL... HEROKU_POSTGRESQL_AMBER_URL
Promoting postgresql-XXXXXXXXX-11111 to DATABASE_URL on ⬢ MYAPP... done
Checking release phase... pg:promote succeeded. It is safe to ignore the failed Detach DATABASE (@ref:postgresql-XXXXXXXXXX-11111) release.
```

This tells us that Heroku switched the previous primary to use the new alias
`HEROKU_POSTGRESQL_AMBER` and that we are good to leave maintenance mode. We
review the new state of the application one more time and run `heroku pg:info`
like above:

```
=== DATABASE_URL, HEROKU_POSTGRESQL_NAVY_URL
Plan:                  Standard 0
Status:                Available
[...]
PG Version:            15.5
[...]
Created:               2024-01-31 02:28
[...]
Forked From:           HEROKU_POSTGRESQL_AMBER
[...]

=== HEROKU_POSTGRESQL_AMBER_URL
Plan:                  Standard 0
Status:                Available
[...]
PG Version:            13.13
[...]
Created:               2022-06-30 07:28
[...]
Forks:                 HEROKU_POSTGRESQL_NAVY
[...]
```

We see that we have two instances:

- `DATABASE_URL`, or `HEROKU_POSTGRESQL_NAVY`, the upgraded follower of
  `HEROKU_POSTGRESQL_NAVY` running PostgreSQL 15.5 and our current primary
  database that the Django backend is talking to.
- `HEROKU_POSTGRESQL_AMBER`, running PostgreSQL 13.13 and being the former
  primary database that `HEROKU_POSTGRESQL_NAVY` followed.

Previously, `DATABASE_URL` in the top would show 13.13 as our PG version, so
we are sure that the primary database has been upgraded successfully.

## Leaving maintenance mode

We leave maintenance mode using `heroku maintenance:off --app MYAPP` and see
the following output:

```
Disabling maintenance mode for ⬢ MYAPP... done
```

We manually test the application by logging in to the backend and frontend
and confirm that everything works well.

## Decommissioning the previous database instance

We have no further for the previous database and are ready to decommission it.
We don't want to leave our user's PII loosely hanging around where it doesn't
serve our user's interests, and of course save $50/month on managed DBMS
costs. We run the following:

```bash
heroku addons:destroy HEROKU_POSTGRESQL_AMBER --app MYAPP
```

We are prompted to one more time confirm this destructive action, and then
we are done:

```
 ▸    WARNING: Destructive Action
 ▸    This command will affect the app MYAPP
 ▸    To proceed, type MYAPP or re-run this command with --confirm MYAPP

> MYAPP
Destroying postgresql-XXXXXXXXXX-11111 on ⬢ MYAPP... done
```

We are done upgrading PostgreSQL on Heroku and we can continue updating all
development environments to use PostgreSQL 15. The changes to the Projectify
backend repository are minimal:

```patch
diff --git a/.circleci/config.yml b/.circleci/config.yml
index 144897e..2b70c4a 100644
--- a/.circleci/config.yml
+++ b/.circleci/config.yml
@@ -16,7 +16,7 @@ executors:
           DJANGO_SETTINGS_MODULE: projectify.settings.test
           DJANGO_CONFIGURATION: Test
           DATABASE_URL: "postgres://projectify:projectify@localhost:5432/projectify"
-      - image: postgres:13.5
+      - image: postgres:15.5
         environment:
           POSTGRES_DB: projectify
           POSTGRES_USER: projectify
diff --git a/README.md b/README.md
index 9593e23..0318953 100644
--- a/README.md
+++ b/README.md
[...] adjust documentation
diff --git a/flake.nix b/flake.nix
index ef9d849..faa4ddd 100644
--- a/flake.nix
+++ b/flake.nix
@@ -17,7 +17,7 @@
         pkgs = nixpkgs.legacyPackages.${system};
         inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryEnv defaultPoetryOverrides;
         projectDir = self;
-        postgresql = pkgs.postgresql_13;
+        postgresql = pkgs.postgresql_15;
         overrides = defaultPoetryOverrides.extend (self: super: {
           django-cloudinary-storage = super.django-cloudinary-storage.overridePythonAttrs (
             old: {
```

On Debian, we install PostgreSQL using

```bash
sudo apt install postgresql-15
```

And that concludes the upgrade procedure.
