defmodule SubjectAccess do
  alias SubjectAccess.Schemas.Student
  alias PgResource.Repo

  def add_user(email) do
    Repo.insert(%Student{email: email})
  end

  def all_users(), do: Student |> Repo.all()
end
