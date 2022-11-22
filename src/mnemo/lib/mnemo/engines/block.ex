defmodule Mnemo.Engines.Block do
  alias Mnemo.Access.Schemas.{Block, ReviewBlock, Section, Enrollment}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  def next_block(enrollment, "review") do
    ReviewBlock
    |> ReviewBlock.where_student(enrollment.student_id)
    |> ReviewBlock.where_subject(enrollment.subject_id)
    |> ReviewBlock.limit(1)
    |> PGRepo.one()
  end

  def next_block(enrollment, "study") do
    if block_cursor_in_completed_blocks?(enrollment) do
      next_study_block(enrollment, enrollment.block_cursor)
    else
      enrollment.block_cursor
    end
  end

  def next_block(enrollment = %Enrollment{}, block = %Block{}, "study") do
    next_study_block(enrollment, block)
  end

  # Checks whether there are any scheduled blocks for today, returns those.
  # Otherwise returns the next block in the subject.
  def next_block(enrollment = %Enrollment{}) do
    review_block = next_block(enrollment, "review")
    review_limit = Application.fetch_env!(:mnemo, :daily_review_limit)

    if not is_nil(review_block) and enrollment.num_reviewed_today < review_limit do
      {"review", review_block}
    else
      {"study", next_block(enrollment, "study")}
    end
  end

  defp next_study_block(nil), do: nil

  defp next_study_block(enrollment, block_cursor) do
    case next_block_in_current_section(block_cursor) do
      nil ->
        current_section = block_cursor_section(block_cursor)

        case next_section(current_section) do
          nil -> nil
          section -> if_completed_get_next(enrollment, first_block_in_section(section))
        end

      block ->
        if_completed_get_next(enrollment, block)
    end
  end

  defp if_completed_get_next(enrollment, block) do
    if block_in_completed_blocks?(enrollment, block) do
      next_study_block(block)
    else
      block
    end
  end

  defp next_block_in_current_section(block_cursor) do
    Block
    |> Block.where_section(block_cursor.section_id)
    |> Block.where_order(block_cursor.order_in_section + 1)
    |> PGRepo.one()
  end

  defp block_cursor_section(block_cursor) do
    Section
    |> Section.where_id(block_cursor.section_id)
    |> PGRepo.one()
  end

  defp next_section(section) do
    Section
    |> Section.where_subject(section.subject_id)
    |> Section.where_order(section.order_in_subject + 1)
    |> PGRepo.one()
  end

  defp first_block_in_section(section) do
    Block
    |> Block.where_section(section.id)
    |> Block.ordered()
    |> Block.limit()
    |> PGRepo.one()
  end

  defp block_cursor_in_completed_blocks?(%{block_cursor: nil}), do: false

  defp block_cursor_in_completed_blocks?(enrollment) do
    Enum.any?(enrollment.completed_blocks, &(&1.id == enrollment.block_cursor.id))
  end

  defp block_in_completed_blocks?(_enrollment, nil), do: false

  defp block_in_completed_blocks?(enrollment, block) do
    Enum.any?(enrollment.completed_blocks, &(&1.id == block.id))
  end

  def test_block(block_id, answer) when is_binary(block_id) do
    Block
    |> Block.where_id(block_id)
    |> PGRepo.one()
    |> test_block(answer)
  end

  def test_block(%Block{} = block, answer) do
    test_block_type(block.type, block, answer)
  end

  def test_block_type("static", %Block{} = _block, answer) do
    is_correct? = answer == "true"
    {:ok, {is_correct?, answer}}
  end

  def test_block_type("fc", %Block{} = _block, answer) do
    is_correct? = answer == "true"
    {:ok, {is_correct?, answer}}
  end

  def test_block_type("saq", %Block{} = block, answer) when is_binary(answer) do
    is_correct? = Enum.any?(block.saq_answer_choices, fn choice -> choice["text"] == answer end)
    details = nil

    {:ok, {is_correct?, details}}
  end

  def test_block_type("fibq", %Block{} = block, answers) do
    # answers is expected to be %{"0" => "blue", "1" => "red"}, where each
    # corresponds to the idx of an input field in the question_structure

    actual_answers =
      Enum.filter(block.fibq_question_structure, fn brick -> brick["type"] == "input" end)

    graded_answers =
      Enum.map(answers, fn {input_idx, answer} ->
        ref =
          Enum.find(actual_answers, fn aa -> aa["input_idx"] == String.to_integer(input_idx) end)

        {input_idx, %{"value" => answer, "correct" => ref["answer"] == answer}}
      end)

    is_block_correct =
      Enum.all?(graded_answers, fn {_idx, answer_struct} -> answer_struct["correct"] end)

    {:ok, {is_block_correct, graded_answers |> Enum.into(%{})}}
  end

  def test_block_type("mcq", %Block{} = block, answer_key) do
    is_block_correct = answer_key == block.mcq_answer_correct

    detail = %{answer_key => false}

    {:ok, {is_block_correct, detail}}
  end
end
