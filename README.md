## On the structure of "src"

Currently Mnemo is structured as a Phoenix monolith - the intention is eventually 
to split portions out into services if need be.

The architecture laid out in the "arch" documents is still preserved, both in 
terms of file structure within `lib`, as well as in the naming of modules 
(with slight adjustments to accommodate elixir conventions).

## Deployment and CI/CD

There is a `pre-commit` git hook configured to check formatting/linting via the
elixir `formatter` and to run tests via `mix test`. Failure of any of these
two commands will stop a commit.

On pushing to main, a `CircleCI` pipeline is configured, which runs two jobs:

The first runs tests in a `test` env, imitating what happens locally on commits.

The second builds a release and runs e2e tests with `playwright`, imitating 
the configuration of our `fly` deployment. If these tests succeeds, the build
is launched to `fly`.

The `flyctl` auth token is kept as a secret in `circleci`.

Once deployed, the server reads envs from the `fly` environment, most importantly
the `SECRET_KEY_BASE` and `DATABASE_URL`.

The `Dockerfile` found in the mnemo `src` folder was created by `flyctl`, and 
modified slightly to include relevant dependencies. It is not used in the 
`CircleCI` flow, only as a deployment container by `fly`.

The Postgres DB for dev & testing is a docker-compose project that runs a
single PG container with a few envs set, and includes a shell script to 
start and to stop the service locally. This can be found in `resources`.

TODO: 
- Split up logic for svelte components in neater fashion (store for every component)
- Consider switch to Vue
- Tests for manager, prioritize over unit tests.
- Tests and specs for functions we created.
