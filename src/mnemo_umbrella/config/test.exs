import Config

config :pg_resource, PgResource.Repo,
  database: "mnemo_test",
  username: "testuser",
  password: "testpass",
  hostname: "localhost"
