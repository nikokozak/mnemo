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

### WEB_CLIENT CONFIG ###

# Configures the endpoint
config :web_client, WebClientWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: WebClientWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: WebClient.PubSub,
  live_view: [signing_salt: "aONQvDUD"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/web_client/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# TailwindCSS Configuration ## TODO: This isn't working
config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../apps/web_client/assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

### END WEB_CLIENT CONFIG ###

import_config "#{config_env()}.exs"
