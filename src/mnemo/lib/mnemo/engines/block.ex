defmodule Mnemo.Engines.Block do
  alias Mnemo.Access.Schemas.{Block, ReviewBlock, Section, Enrollment}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  # Checks whether there are any scheduled blocks for today, returns those.
  # Otherwise returns the next block in the subject.
  def next_block(enrollment = %Enrollment{}) do
    current_block = enrollment.block_cursor

    review_block =
      ReviewBlock
      |> ReviewBlock.where_student(enrollment.student_id)
      |> ReviewBlock.where_subject(enrollment.subject_id)
      |> ReviewBlock.limit()
      |> PGRepo.one()

    if not is_nil(review_block) do
      {"review", review_block}
    else
      next_block_in_current_section =
        Block
        |> Block.where_section(current_block.section_id)
        |> Block.where_order(current_block.order_in_section + 1)
        |> PGRepo.one()

      case next_block_in_current_section do
        nil ->
          current_section =
            Section
            |> Section.where_id(current_block.section_id)
            |> PGRepo.one()

          next_section =
            Section
            |> Section.where_subject(current_section.subject_id)
            |> Section.where_order(current_section.order_in_subject + 1)
            |> PGRepo.one()

          case next_section do
            nil ->
              {"subject", nil}

            section ->
              next_subject_block =
                Block
                |> Block.where_section(section.id)
                |> Block.ordered()
                |> Block.limit()
                |> PGRepo.one()

              {"subject", next_subject_block}
          end

        block ->
          {"subject", block}
      end
    end
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
      Enum.all?(graded_answers, fn {idx, answer_struct} -> answer_struct["correct"] end)

    {:ok, {is_block_correct, graded_answers |> Enum.into(%{})}}
  end

  def test_block_type("mcq", %Block{} = block, answer_key) do
    is_block_correct = answer_key == block.mcq_answer_correct

    detail = %{answer_key => false}

    {:ok, {is_block_correct, detail}}
  end
end
