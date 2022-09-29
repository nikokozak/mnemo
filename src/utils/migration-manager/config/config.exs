import Config

config :migration_manager, Mnemo.Repo,
  database: "migration_manager_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"
