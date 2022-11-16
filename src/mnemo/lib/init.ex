defmodule Mnemo.Init do
  def seed() do
    Mnemo.Resources.Postgres.Repo.insert!(%Mnemo.Access.Schemas.Student{
        id: "dd48cfda-5f8d-4c9e-8968-04a75ec08df4",
        email: "nikokozak@gmail.com"
    })
  end
end
