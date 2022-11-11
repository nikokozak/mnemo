defmodule Mnemo.Managers.Course do
  alias Mnemo.Engines.Block, as: BlockEngine
  alias Mnemo.Access.Schemas.{Subject, Section, Block, Enrollment}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  def new_subject(_student_id) do
    student_id = Application.fetch_env!(:mnemo, :test_student_id)

    %Subject{}
    |> Subject.create_changeset(%{student_id: student_id})
    |> PGRepo.insert()
  end

  def save_subject(subject_id, new_params) do
    %Subject{id: subject_id}
    |> Subject.update_changeset(new_params)
    |> PGRepo.update()
  end

  def delete_subject(subject_id) do
    %Subject{id: subject_id}
    |> Subject.delete_changeset()
    |> PGRepo.delete()
  end

  def new_section(subject_id) do
    %Section{}
    |> Section.create_changeset(%{subject_id: subject_id})
    |> PGRepo.insert()
  end

  def save_section(section_id, new_params) do
    %Section{id: section_id}
    |> Section.update_changeset(new_params)
    |> PGRepo.update()
  end

  def delete_section(section_id) do
    Section
    |> Section.where_id(section_id)
    |> PGRepo.one()
    |> Section.delete_changeset()
    |> PGRepo.delete()
  end

  def new_block(subject_id, section_id, block_type) do
    %Block{}
    |> Block.create_changeset(%{
          section_id: section_id,
          subject_id: subject_id,
          type: block_type})
          |> PGRepo.insert()
  end

  def save_block(block, new_params) do
    block
    |> Block.update_changeset(new_params)
    |> PGRepo.update()
  end

  def test_block(block_id, answer) do
    BlockEngine.test_block(block_id, answer)
  end

  def delete_block(block_id) do
    Block
    |> Block.where_id(block_id)
    |> PGRepo.one()
    |> Block.delete_changeset()
    |> PGRepo.delete()
  end

  def new_enrollment(_student_id, subject_id) do
    student_id = Application.fetch_env!(:mnemo, :test_student_id)

    %Enrollment{}
    |> Enrollment.create_changeset(%{student_id: student_id, subject_id: subject_id})
    |> PGRepo.insert()
  end

  def move_cursor_enrollment(enrollment, new_cursor_block_id) do
    enrollment
    |> Enrollment.new_cursor_changeset(new_cursor_block_id)
    |> PGRepo.update()
  end

  def consume_cursor_enrollment(enrollment) do
    next_block = Block.next_block(enrollment.block_cursor)

    enrollment
    |> Enrollment.consume_cursor_changeset()
    |> Enrollment.new_cursor_changeset(next_block)
    |> PGRepo.update!()
    |> PGRepo.preload(block_cursor: :section)
  end

  def delete_enrollment(enrollment_id) do
    Enrollment
    |> Enrollment.where_id(enrollment_id)
    |> PGRepo.one()
    |> Enrollment.delete_changeset()
    |> PGRepo.delete()
  end

end
