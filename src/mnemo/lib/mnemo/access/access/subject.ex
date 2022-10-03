defmodule Mnemo.Access.Subject do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{Student}

  def new_subject(student_id) do
    PGRepo.get(Student, student_id)
    |> Ecto.build_assoc(:subjects)
    |> PGRepo.insert()
  end

  def student_subjects(student_id) do
    student =
      PGRepo.get(Student, student_id)
      |> PGRepo.preload(:subjects)

    student.subjects
  end
end
