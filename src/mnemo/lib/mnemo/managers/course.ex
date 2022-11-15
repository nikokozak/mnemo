defmodule Mnemo.Managers.Course do
  alias Mnemo.Engines.Block, as: BlockEngine
  require Ecto.Query

  alias Mnemo.Access.Schemas.{
    Subject,
    Section,
    Block,
    Enrollment,
    CompletedReviewBlock,
    ScheduledBlock
  }

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
      type: block_type
    })
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

  def consume_cursor_enrollment(enrollment, answer_success?, answers) do
    IO.inspect(answers, label: "Answers in consume cursor enrollment")
    {:ok, completed_block} = complete_block(enrollment, answer_success?, answers)

    schedule_block(enrollment, completed_block)

    next_block = Block.next_block(enrollment.block_cursor)

    enrollment
    |> Enrollment.consume_cursor_changeset()
    |> Enrollment.new_cursor_changeset(next_block)
    |> PGRepo.update!()
    |> PGRepo.preload(block_cursor: :section)
  end

  defp complete_block(enrollment, answer_success?, answers) do
    last_completed_block =
      CompletedReviewBlock
      |> CompletedReviewBlock.where_student(enrollment.student_id)
      |> CompletedReviewBlock.where_block(enrollment.block_cursor.id)
      |> CompletedReviewBlock.sort_by_date()
      |> Ecto.Query.limit(1)
      |> PGRepo.one()

    IO.inspect(last_completed_block, label: "Last completed block")

    params = %{
      student_id: enrollment.student_id,
      subject_id: enrollment.subject_id,
      block_id: enrollment.block_cursor.id,
      succeeded: answer_success?,
      answers: answers,
      time_taken: 0
    }

    if not is_nil(last_completed_block) do
      {:ok, completed_block} =
        %CompletedReviewBlock{}
        |> CompletedReviewBlock.create_changeset(
          Map.merge(params, %{
            correct_in_a_row: last_completed_block.correct_in_a_row
          })
        )
        |> PGRepo.insert()
    else
      %CompletedReviewBlock{}
      |> CompletedReviewBlock.create_changeset(params)
      |> PGRepo.insert()
    end
  end

  defp schedule_block(enrollment, completed_review_block) do
    existing_block =
      ScheduledBlock
      |> ScheduledBlock.where_student(enrollment.student_id)
      |> ScheduledBlock.where_block(enrollment.block_cursor.id)
      |> PGRepo.one()

    if not is_nil(existing_block) do
      {:ok, scheduled_block} =
        %ScheduledBlock{id: existing_block.id}
        |> ScheduledBlock.update_changeset(%{
          review_at: Date.utc_today() |> Date.add(completed_review_block.interval_to_next_review)
        })
        |> PGRepo.update()

      scheduled_block
    else
      {:ok, scheduled_block} =
        %ScheduledBlock{}
        |> ScheduledBlock.create_changeset(%{
          student_id: enrollment.student_id,
          subject_id: enrollment.subject_id,
          block_id: enrollment.block_cursor.id,
          review_at: Date.utc_today() |> Date.add(completed_review_block.interval_to_next_review)
        })
        |> PGRepo.insert()

      scheduled_block
    end
  end

  def delete_enrollment(enrollment_id) do
    Enrollment
    |> Enrollment.where_id(enrollment_id)
    |> PGRepo.one()
    |> Enrollment.delete_changeset()
    |> PGRepo.delete()
  end
end
