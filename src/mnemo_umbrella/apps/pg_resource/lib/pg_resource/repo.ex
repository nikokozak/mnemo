defmodule PgResource.Repo do
  use Ecto.Repo,
    otp_app: :pg_resource,
    adapter: Ecto.Adapters.Postgres
end
