defmodule MigrationManager do
  use Application

  def start(_type, _args) do
    children = [
      Mnemo.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
