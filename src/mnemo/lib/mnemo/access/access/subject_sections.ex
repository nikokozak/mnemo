defmodule Mnemo.Access.SubjectSections do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{Subject, SubjectSection}

  def create(subject_id) do
    PGRepo.get(Subject, subject_id)
    |> Ecto.build_assoc(:sections)
    |> PGRepo.insert()
  end

  def save(section) do
    Ecto.Changeset.cast(%SubjectSection{id: section["id"]}, section, [
      :title
    ])
    |> PGRepo.update()
  end

  def delete(section_id) do
    PGRepo.get(SubjectSection, section_id)
    |> PGRepo.delete()
  end
end
