defmodule Mnemo.Repo do
  use Ecto.Repo,
    otp_app: :migration_manager,
    adapter: Ecto.Adapters.Postgres
end
