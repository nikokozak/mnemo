## On the structure of "src"

Currently Mnemo is structured as an umbrella app, with different apps representing the various services of the application.

Initially, all web clients will exist as one main Phoenix project, which can then be split up into different services if need be. This is to avoid the 9 web services we'd otherwise have to create.

The same will happen with ResourceAccess services, which will all live under the same service.

The PGResource service acts as the Repo link to Postgres.

Being an umbrella app, all services share config and deps.

A pre-commit git hook has been created that runs `mix format` and `mix test` on every app in the umbrella before allowing a commit.

The Postgres DB for dev & testing is a docker-compose project that runs a single PG container with a few envs set, and includes a shell script to start and to stop the service.

## App Structre

At the moment:

- pg_resource: the actual Repo for interacting with postgres resource. 
- subject_access: a library for accessing the pg_resource. Holds 'subject_access', 'student_progression_access', and 'user_review_queue_access' atm.
- content_manager: the content manager.
- web_client: a phoenix web client that encompasses all our client services at the moment, EXCEPT for the auth utility which is split off (not built yet)
