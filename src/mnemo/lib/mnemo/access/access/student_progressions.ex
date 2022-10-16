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
      left_join: cb in ContentBlock,
      on: cb.id == sp.content_block_cursor_id,
      left_join: sec in SubjectSection,
      on: sec.id == cb.subject_section_id,
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
        where: cb.order_in_section == 0,
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

  def move_cursor_to(progression_id, new_block_id) do
    progression =
      PGRepo.get(StudentProgression, progression_id)
      |> PGRepo.preload(:content_block_cursor)

    new_block = PGRepo.get(ContentBlock, new_block_id)

    Ecto.Changeset.change(progression)
    |> Ecto.Changeset.put_assoc(:content_block_cursor, new_block)
    |> PGRepo.update()
  end

  def mark_block_completed(progression_id) do
    progression = get_progression(progression_id)
    completed_blocks = [progression.content_block_cursor | progression.completed_blocks]
    next_block = get_next_block(progression)
    cursor_at_end? = if is_nil(next_block), do: true, else: false
    completed? = completed?(progression.subject_id, completed_blocks)

    Ecto.Changeset.change(progression)
    |> Ecto.Changeset.cast(%{cursor_at_end: cursor_at_end?, completed: completed?}, [
      :cursor_at_end,
      :completed
    ])
    |> Ecto.Changeset.put_assoc(:completed_blocks, completed_blocks)
    |> Ecto.Changeset.put_assoc(:content_block_cursor, next_block)
    |> PGRepo.update()
  end

  defp completed?(subject_id, completed_blocks) do
    blocks_in_subject =
      from(s in SubjectSection,
        where: s.subject_id == ^subject_id,
        join: b in ContentBlock,
        where: b.subject_section_id == s.id,
        select: b
      )
      |> PGRepo.all()

    Enum.all?(blocks_in_subject, fn block -> block in completed_blocks end)
  end

  defp get_progression(progression_id) do
    PGRepo.get(StudentProgression, progression_id)
    |> PGRepo.preload([
      :content_block_cursor,
      :completed_sections,
      :completed_blocks
    ])
  end

  defp get_next_block(%StudentProgression{} = progression) do
    current_block =
      progression |> PGRepo.preload(:content_block_cursor) |> Map.get(:content_block_cursor)

    case next_block_in_current_section(current_block) do
      nil ->
        next_block_in_next_section(current_block)

      block ->
        block
    end
  end

  defp next_block_in_current_section(%ContentBlock{} = current_block) do
    from(b in ContentBlock,
      where: b.subject_section_id == ^current_block.subject_section_id,
      where: b.order_in_section == ^current_block.order_in_section + 1
    )
    |> PGRepo.one()
  end

  defp next_block_in_next_section(%ContentBlock{} = current_block) do
    case next_section(current_block.subject_section_id) do
      nil ->
        nil

      section ->
        from(b in ContentBlock,
          where: b.subject_section_id == ^section.id,
          where: b.order_in_section == 0
        )
        |> PGRepo.one()
    end
  end

  defp next_section(current_section_id) do
    current_section = PGRepo.get(SubjectSection, current_section_id)

    from(s in SubjectSection,
      where: s.subject_id == ^current_section.subject_id,
      where: s.order_in_subject == ^current_section.order_in_subject + 1
    )
    |> PGRepo.one()
  end

  defp section_completed?(completed_blocks, section) do
    Enum.all?(section.content_blocks, fn block_in_section ->
      block_in_section in completed_blocks
    end)
  end

  def save(student_progression) do
    Ecto.Changeset.cast(%StudentProgression{id: student_progression["id"]}, student_progression, [
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

  def delete_all_with_subject(subject_id) do
    Ecto.Query.from(
      s in StudentProgression,
      where: s.subject_id == ^subject_id
    )
    |> PGRepo.delete_all()
  end
end
