defmodule Mnemo.Managers.Course do
  alias Mnemo.Engines.Block, as: BlockEngine
  require Ecto.Query

  alias Mnemo.Access.Schemas.{
    Subject,
    Section,
    Block,
    Enrollment,
    CompletedReviewBlock,
    ScheduledBlock,
    ReviewBlock
  }

  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  @spec new_subject(student_id :: String.t()) :: {:ok, %Subject{}} | {:error, %Ecto.Changeset{}}
  def new_subject(student_id) do
    %Subject{}
    |> Subject.create_changeset(%{student_id: student_id})
    |> PGRepo.insert()
  end

  @spec update_subject(subject_id :: String.t(), new_params :: map()) ::
          {:ok, %Subject{}} | {:error, %Ecto.Changeset{}}
  def update_subject(subject_id, new_params) do
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

  def update_section(section_id, new_params) do
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

  def update_block(block, new_params) do
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

  def new_enrollment(student_id, subject_id) do
    %Enrollment{}
    |> Enrollment.create_changeset(%{student_id: student_id, subject_id: subject_id})
    |> PGRepo.insert()
  end

  # TODO: unnecessary
  def move_cursor_enrollment(enrollment, new_cursor_block_id) do
    enrollment
    |> Enrollment.new_cursor_changeset(new_cursor_block_id, "subject")
    |> PGRepo.update()
  end

  def delete_enrollment(enrollment_id) do
    Enrollment
    |> Enrollment.where_id(enrollment_id)
    |> PGRepo.one()
    |> Enrollment.delete_changeset()
    |> PGRepo.delete()
  end

  def next_block(enrollment) do
    BlockEngine.next_block(enrollment)
  end

  @doc """
  Consumes the current block in the block viewer, if the block is a "study" block and not a "review" block.
  If the latest answer out of the answer attempts is correct, or if enough attempts have been made, it will:
  - Add the completed block to CompletedReviewBlocks,
  - Schedule the completed block for review in ScheduledBlocks,
  - Add the completed block to completed_blocks in the Enrollment,
  - Look up the next block in the Subject, and place this as the block_cursor in the Enrollment
  - Set the completed block as the last_completed_block in the Enrollment
  """
  def consume_block(enrollment, block, block_type, answer_attempts) do
    latest_answer = List.first(answer_attempts)
    {:ok, {correct?, correction_details}} = BlockEngine.test_block(block, latest_answer)

    if correct? or length(answer_attempts) == 3 do
      do_consume(enrollment, block, block_type, correct?, answer_attempts)
    else
      {:incorrect, correction_details}
    end
  end

  defp do_consume(enrollment, block, block_type, correct?, answer_attempts) do
    # TODO: This should be a Multi
    {:ok, completed_block} = complete_block(enrollment, block, correct?, answer_attempts)
    {:ok, _scheduled_block} = schedule_block(enrollment, block, completed_block)

    # TODO: This is soooo hacky
    enrollment =
      case block_type do
        "review" ->
          {:ok, _deleted_block} = remove_block_from_review_queue(enrollment, block)
          enrollment
        "study" ->
          consume_and_assign_next_block_cursor(enrollment, block)
      end

    {block_type, next_review_block} = BlockEngine.next_block(enrollment)

    {:correct, {block_type, next_review_block, enrollment}}
  end

  defp remove_block_from_review_queue(enrollment, block) do
    ReviewBlock
    |> ReviewBlock.where_student(enrollment.student_id)
    |> ReviewBlock.where_subject(enrollment.subject_id)
    |> ReviewBlock.where_block(block.id)
    |> PGRepo.one()
    |> PGRepo.delete()
  end

  def consume_and_assign_next_block_cursor(enrollment, block) do
    next_block = BlockEngine.next_block(enrollment, block, "study")

    enrollment
    |> Enrollment.consume_cursor_changeset()
    |> Enrollment.new_cursor_changeset(next_block)
    |> PGRepo.update!()
    |> PGRepo.preload(block_cursor: :section)
  end

  defp complete_block(enrollment, block, answer_success?, answers) do
    last_answer_attempt = get_last_similar_completed_block(enrollment, block)

    completed_block_params = %{
      student_id: enrollment.student_id,
      subject_id: enrollment.subject_id,
      block_id: block.id,
      succeeded: answer_success?,
      answers: answers,
      time_taken: 0
    }

    insert_completed_block(completed_block_params, last_answer_attempt)
  end

  defp get_last_similar_completed_block(enrollment, block) do
    CompletedReviewBlock
    |> CompletedReviewBlock.where_student(enrollment.student_id)
    |> CompletedReviewBlock.where_block(block.id)
    |> CompletedReviewBlock.sort_by_date()
    |> Ecto.Query.limit(1)
    |> PGRepo.one()
  end

  defp insert_completed_block(new_block_params, nil) do
    %CompletedReviewBlock{}
    |> CompletedReviewBlock.create_changeset(new_block_params)
    |> PGRepo.insert()
  end

  defp insert_completed_block(new_block_params, last_answer_attempt) do
    if completed_on_same_date_as_last_attempt?(last_answer_attempt) do
      {:ok, last_answer_attempt}
    else
      Map.merge(
        new_block_params,
        # We don't pass in correct_in_a_row + 1 because the changeset will
        # automatically handle the correct_in_a_row value depending on the
        # :succeeded value of the params passed in.
        %{correct_in_a_row: last_answer_attempt.correct_in_a_row}
      )
      |> insert_completed_block(nil)
    end
  end

  defp completed_on_same_date_as_last_attempt?(last_answer_attempt),
    do: Date.compare(Date.utc_today(), last_answer_attempt.datetime_completed) == :eq

  defp schedule_block(enrollment, block, completed_review_block) do
    # TODO: add logic to avoid updating when we're just passing through a block
    # that's been completed multiple times on the same day.
    previous_scheduled_block = get_scheduled_block(enrollment, block)

    insert_or_update_scheduled_block(
      enrollment,
      block,
      completed_review_block,
      previous_scheduled_block
    )
  end

  defp get_scheduled_block(enrollment, block) do
    ScheduledBlock
    |> ScheduledBlock.where_student(enrollment.student_id)
    |> ScheduledBlock.where_block(block.id)
    |> PGRepo.one()
  end

  defp insert_or_update_scheduled_block(enrollment, block, completed_review_block, nil) do
    %ScheduledBlock{}
    |> ScheduledBlock.create_changeset(%{
      student_id: enrollment.student_id,
      subject_id: enrollment.subject_id,
      block_id: block.id,
      review_at: Date.utc_today() |> Date.add(completed_review_block.interval_to_next_review)
    })
    |> PGRepo.insert()
  end

  defp insert_or_update_scheduled_block(
         _enrollment,
         _block,
         completed_review_block,
         previous_scheduled_block
       ) do
    %ScheduledBlock{id: previous_scheduled_block.id}
    |> ScheduledBlock.update_changeset(%{
      review_at: Date.utc_today() |> Date.add(completed_review_block.interval_to_next_review)
    })
    |> PGRepo.update()
  end
end
