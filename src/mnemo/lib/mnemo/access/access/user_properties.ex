defmodule Mnemo.Access.UserProperties do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{Student}

  def new_student(email) do
    PGRepo.insert(%Student{email: email})
  end

  def students() do
    Student
    |> PGRepo.all()
  end
end
