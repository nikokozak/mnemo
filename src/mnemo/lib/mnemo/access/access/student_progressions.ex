defmodule Mnemo.Access.StudentProgressions do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{Student, Subject, SubjectSection, ContentBlock, StudentProgression}
  require Ecto.Query

  def get(student_id, subject_id) do
    StudentProgression
    |> Ecto.Query.where(owner_id: ^student_id)
    |> Ecto.Query.where(subject_id: ^subject_id)
    |> PGRepo.one()
  end

  def create(student_id, subject_id) do
    student = PGRepo.get(Student, student_id)
    subject = PGRepo.get(Subject, subject_id) |> PGRepo.preload([:sections])
    first_section = subject.sections |> List.first()
    section_content = first_section |> PGRepo.preload([:content_blocks])
    first_content_block = section_content.content_blocks |> List.first()

    Ecto.Changeset.change(%StudentProgression{owner_id: student.email})
    |> Ecto.Changeset.put_assoc(:subject, subject)
    |> Ecto.Changeset.put_assoc(:subject_section_cursor, first_section)
    |> Ecto.Changeset.put_assoc(:content_block_cursor, first_content_block)
    |> Ecto.Changeset.put_assoc(:completed_sections, [])
    |> Ecto.Changeset.put_assoc(:completed_blocks, [])
    |> Ecto.Changeset.unique_constraint([:owner_id, :subject_id],
      name: :owner_id_subject_id_unique_index
    )
    |> PGRepo.insert()
  end

  def save(student_id, subject_id, section_id, block_id) do
    section = PGRepo.get(SubjectSection, section_id)
    block = PGRepo.get(ContentBlock, block_id)

    progression =
      StudentProgression
      |> Ecto.Query.where(owner_id: ^student_id)
      |> Ecto.Query.where(subject_id: ^subject_id)
      |> PGRepo.one()
      |> PGRepo.preload([
        :completed_sections,
        :completed_blocks,
        :subject_section_cursor,
        :content_block_cursor
      ])

    progression
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:completed_sections, [
      progression.subject_section_cursor | progression.completed_sections
    ])
    |> Ecto.Changeset.put_assoc(:completed_blocks, [
      progression.content_block_cursor | progression.completed_blocks
    ])
    |> Ecto.Changeset.put_assoc(:subject_section_cursor, section)
    |> Ecto.Changeset.put_assoc(:content_block_cursor, block)
    |> PGRepo.update()
  end

  def save(student_progression) do
    Ecto.Changeset.cast(%StudentProgression{id: student_progression["id"]}, student_progression, [
      :subject_section_cursor,
      :content_block_cursor,
      :completed_sections,
      :completed_blocks
    ])
    |> PGRepo.update()
  end

  def delete(student_progression_id) do
    PGRepo.get(StudentProgression, student_progression_id)
    |> PGRepo.delete()
  end
end
