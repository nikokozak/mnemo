defmodule Mnemo.Resources.Postgres.Repo do
  use Ecto.Repo,
    otp_app: :mnemo,
    adapter: Ecto.Adapters.Postgres
end
