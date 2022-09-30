# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :pg_resource, ecto_repos: [PgResource.Repo]

config :pg_resource, PgResource.Repo, migration_primary_key: [name: :id, type: :binary_id]

import_config "#{config_env()}.exs"
