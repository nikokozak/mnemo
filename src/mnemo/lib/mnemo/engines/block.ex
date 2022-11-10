defmodule Mnemo.Engines.Block do
  alias Mnemo.Access.Schemas.Block
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  def test_block(block_id, answer) when is_binary(block_id) do
    Block
    |> Block.where_id(block_id)
    |> PGRepo.one()
    |> test_block(answer)
  end

  def test_block(%Block{} = block, answer) do
    test_block_type(block.type, block, answer)
  end

  def test_block_type("static", %Block{} = _block, _answer) do
    # Static blocks are always "correct" when tested
    {:ok, true}
  end

  def test_block_type("saq", %Block{} = block, %{"answer" => answer}) when is_binary(answer) do
    is_correct? = Enum.any?(block.saq_answer_choices, fn choice -> choice["text"] == answer end)
    details = nil

    {:ok, {is_correct?, details}}
  end

  def test_block_type("fibq", %Block{} = block, answers) do
    # answers is expected to be %{"0" => "blue", "1" => "red"}, where each
    # corresponds to the idx of an input field in the question_structure

    actual_answers =
      Enum.filter(block.fibq_question_structure, fn brick -> brick["type"] == "input" end)

    graded_answers = Enum.map(answers, fn {input_idx, answer} ->
      ref = Enum.find(actual_answers, fn aa -> aa["input_idx"] == String.to_integer(input_idx) end)

      {input_idx, %{"value" => answer, "correct" => ref["answer"] == answer}}
    end)

    is_block_correct = Enum.all?(graded_answers, fn {idx, answer_struct} -> answer_struct["correct"] end)

    {:ok, {is_block_correct, graded_answers |> Enum.into(%{})}}
  end

  def test_block_type("mcq", %Block{} = block, answer_key) do
    is_block_correct = answer_key == block.mcq_answer_correct

    detail = %{answer_key => false }

    {:ok, {is_block_correct, detail}}
  end

end
