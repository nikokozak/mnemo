defmodule Core.Access.Subject do
  alias Core.Resources.Postgres.Repo, as: PGRepo
  alias Core.Access.Schemas.Student

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
