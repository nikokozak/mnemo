defmodule MigrationManager.MixProject do
  use Mix.Project

  def project do
    [
      app: :migration_manager,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.9.0"},
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
