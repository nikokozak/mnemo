defmodule Mnemo.Access.StudentProgressions do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{Student, Subject, SubjectSection, ContentBlock, StudentProgression}
  require Ecto.Query
  import Ecto.Query, only: [from: 2]

  def one(progression_id) do
    Ecto.Query.from(
      sp in StudentProgression,
      where: sp.id == ^progression_id,
      join: sub in Subject,
      on: sub.id == sp.subject_id,
      join: cb in ContentBlock,
      on: cb.id == sp.content_block_cursor_id,
      join: sec in SubjectSection,
      on: sec.id == cb.section_id,
      select: %{
        id: sp.id,
        subject: sub,
        current_section: sec,
        content_block_cursor: cb
      }
    )
    |> PGRepo.one()
  end

  def get(student_id, subject_id) do
    StudentProgression
    |> Ecto.Query.where(owner_id: ^student_id)
    |> Ecto.Query.where(subject_id: ^subject_id)
    |> PGRepo.one()
  end

  def all(student_id) do
    progressions =
      Ecto.Query.from(
        sp in StudentProgression,
        where: sp.owner_id == ^student_id,
        join: s in Subject,
        on: s.id == sp.subject_id,
        select: %{id: sp.id, subject: %{id: s.id, title: s.title}}
      )
      |> PGRepo.all()

    case progressions do
      nil -> []
      progs -> progs
    end
  end

  def create(student_id, subject_id) do
    student = PGRepo.get(Student, student_id)
    subject = PGRepo.get(Subject, subject_id) |> PGRepo.preload(:sections)

    first_content_block =
      from(s in SubjectSection,
        where: s.subject_id == ^subject_id,
        where: s.order_in_subject == 0,
        join: cb in ContentBlock,
        on: cb.subject_section_id == s.id,
        select: cb
      )
      |> PGRepo.one()

    Ecto.Changeset.change(%StudentProgression{owner_id: student.email})
    |> Ecto.Changeset.put_assoc(:subject, subject)
    |> Ecto.Changeset.put_assoc(:content_block_cursor, first_content_block)
    |> Ecto.Changeset.put_assoc(:completed_sections, [])
    |> Ecto.Changeset.put_assoc(:completed_blocks, [])
    |> Ecto.Changeset.unique_constraint([:owner_id, :subject_id],
      name: :owner_id_subject_id_unique_index
    )
    |> PGRepo.insert()
  end

  def save(student_id, subject_id, block_id) do
    block = PGRepo.get(ContentBlock, block_id)

    progression =
      StudentProgression
      |> Ecto.Query.where(owner_id: ^student_id)
      |> Ecto.Query.where(subject_id: ^subject_id)
      |> PGRepo.one()
      |> PGRepo.preload([
        :completed_sections,
        :completed_blocks,
        :content_block_cursor
      ])

    content_block = progression.content_block_cursor |> PGRepo.preload(:subject_section)
    completed_section = content_block.subject_section

    progression
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:completed_sections, [
      completed_section | progression.completed_sections
    ])
    |> Ecto.Changeset.put_assoc(:completed_blocks, [
      progression.content_block_cursor | progression.completed_blocks
    ])
    |> Ecto.Changeset.put_assoc(:content_block_cursor, block)
    |> PGRepo.update()
  end

  def replace_content_block_cursors(new_content_block) do
    subject_id = new_content_block.subject_id

    Ecto.Query.from(
      s in StudentProgression,
      where: s.subject_id == ^subject_id,
      update: [
        set: [
          content_block_cursor_id: ^new_content_block.id
        ]
      ]
    )
    |> PGRepo.update_all([])
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
