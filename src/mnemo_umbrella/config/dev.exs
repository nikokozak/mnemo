import Config

config :pg_resource, PgResource.Repo,
  database: "mnemo_dev",
  username: "testuser",
  password: "testpass",
  hostname: "localhost"
