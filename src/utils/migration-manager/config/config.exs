import Config

config :migration_manager, ecto_repos: [Mnemo.Repo]

config :migration_manager, Mnemo.Repo, migration_primary_key: [name: :id, type: :binary_id]
