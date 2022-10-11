defmodule Mnemo.Access.Subjects do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{Student, Subject, SubjectSection}

  @spec create(student_id: String.t()) :: {:ok, %Subject{}} | {:error, Ecto.Changeset.t()}
  def create(student_id) do
    PGRepo.get(Student, student_id)
    |> Ecto.build_assoc(:subjects)
    |> PGRepo.insert()
  end

  @spec delete(student_id: String.t()) :: {:ok, %Subject{}} | {:error, Ecto.Changeset.t()}
  def delete(subject_id) do
    PGRepo.get(Subject, subject_id)
    |> PGRepo.delete()
  end

  @spec save(subject: map()) :: {:ok, %Subject{}} | {:error, Ecto.Changeset.t()}
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

  @spec all(student_id: String.t()) :: list() | list(%Subject{})
  def all(student_id) do
    case PGRepo.get(Student, student_id) do
      nil ->
        []

      student ->
        PGRepo.preload(student, :subjects)
        |> Map.get(:subjects, [])
    end
  end

  @spec one(subject_id: String.t()) :: nil | %Subject{}
  def one(subject_id) do
    PGRepo.get(Subject, subject_id)
  end

  @spec sections(subject_id: String.t()) :: list() | list(%SubjectSection{})
  def sections(subject_id) do
    PGRepo.get(Subject, subject_id)
    |> PGRepo.preload(:sections)
    |> Map.get(:sections, [])
  end
end
