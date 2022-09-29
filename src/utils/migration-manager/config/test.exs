import Config

config :migration_manager, Mnemo.Repo,
  database: "mnemo_test",
  username: "testuser",
  password: "testpass",
  hostname: "localhost"
