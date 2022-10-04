defmodule Mnemo.Access.Subject do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{Student, Subject}

  def new_subject(student_id) do
    PGRepo.get(Student, student_id)
    |> Ecto.build_assoc(:subjects)
    |> PGRepo.insert()
  end

  def delete_subject(subject_id) do
    PGRepo.get(Subject, subject_id)
    |> PGRepo.delete()
  end

  def save_subject(subject) do
    Ecto.Changeset.cast(%Subject{id: subject["id"]}, subject, [
      :id,
      :title,
      :description,
      :published,
      :private,
      :institution_only,
      :price
    ])
    |> IO.inspect()
    |> PGRepo.update()
  end

  def student_subjects(student_id) do
    case PGRepo.get(Student, student_id) do
      nil ->
        []

      student ->
        PGRepo.preload(student, :subjects)
        |> Map.get(:subjects, [])
    end
  end

  def subject(subject_id) do
    PGRepo.get(Subject, subject_id)
  end
end
