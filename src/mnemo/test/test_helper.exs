ExUnit.configure(exclude: :skip)
ExUnit.start()
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(Mnemo.Resources.Postgres.Repo, :manual)
