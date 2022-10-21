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

  def test_block_type("mcq", %Block{} = block, answer_key) when is_binary(answer_key) do
    # Should always receive the "key" of the given answer
    {:ok, block.mcq_answer_correct == answer_key}
  end

  def test_block_type("saq", %Block{} = block, answer) when is_binary(answer) do
    {:ok,
     Enum.any?(block.saq_answer_choices, fn choice ->
       choice["text"] == answer
     end)}
  end

  def test_block_type("fc", %Block{} = _block, _answer) do
    # Flash Card blocks are always "correct" when tested
    {:ok, true}
  end

  def test_block_type("fibq", %Block{} = block, answer_list) do
    correct_answers = block.fibq_question_answers |> Enum.map(& &1["text"])

    {:ok,
     Enum.all?(correct_answers, fn ca ->
       Enum.find_value(answer_list, false, fn al -> al == ca end)
     end)}
  end
end
