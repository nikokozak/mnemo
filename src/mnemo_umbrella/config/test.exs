import Config

### CORE CONFIG ###
config :core, Core.Resources.Postgres.Repo,
  database: "mnemo_test",
  username: "testuser",
  password: "testpass",
  hostname: "localhost"

### END CORE CONFIG ###

### WEB_CLIENT CONFIG ###

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :web_client, WebClientWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "tFohtK1K7igCf9BOSpSXyAJxiUaTpgVFOgybgKCDlfhmYeepe10Mxim95t4rFX4N",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

### END WEB_CLIENT CONFIG ###
