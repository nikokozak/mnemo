defmodule Mnemo.Access.Subject do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.Student

  def add_user(email) do
    PGRepo.insert(%Student{email: email})

    Student
    |> PGRepo.all()
  end

  def users() do
    Student
    |> PGRepo.all()
  end
end
