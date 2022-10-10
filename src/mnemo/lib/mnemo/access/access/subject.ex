defmodule Mnemo.Access.Subject do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{Student, Subject}

  def create(student_id) do
    PGRepo.get(Student, student_id)
    |> Ecto.build_assoc(:subjects)
    |> PGRepo.insert()
  end

  def delete(subject_id) do
    PGRepo.get(Subject, subject_id)
    |> PGRepo.delete()
  end

  def save(subject) do
    Ecto.Changeset.cast(%Subject{id: subject["id"]}, subject, [
      :title,
      :description,
      :published,
      :private,
      :institution_only,
      :price
    ])
    |> PGRepo.update()
  end

  def all(student_id) do
    case PGRepo.get(Student, student_id) do
      nil ->
        []

      student ->
        PGRepo.preload(student, :subjects)
        |> Map.get(:subjects, [])
    end
  end

  def one(subject_id) do
    PGRepo.get(Subject, subject_id)
  end

  def sections(subject_id) do
    PGRepo.get(Subject, subject_id)
    |> PGRepo.preload(:sections)
    |> Map.get(:sections, [])
  end
end
