defmodule Mnemo.Engines.Block do
  alias Mnemo.Access.Schemas.Block
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  def test_block(block_id, answer) when is_binary(block_id) do
    Block
    |> Block.where_id(block_id)
    |> PGRepo.one()
    |> test_block(answer)
  end

  # Returns a tuple, where the first el is whether the entire block is correct, and second is details.
  def test_block(%Block{} = block, answer) do
    test_block_type(block.type, block, answer)
  end

  def test_block_type("static", %Block{} = _block, _answer) do
    # Static blocks are always "correct" when tested
    {:ok, {true, true}}
  end

  def test_block_type("mcq", %Block{} = block, answer_key) when is_binary(answer_key) do
    # Should always receive the "key" of the given answer

    is_block_correct = block.mcq_answer_correct == answer_key

    {:ok, {is_block_correct, is_block_correct}}
  end

  def test_block_type("saq", %Block{} = block, answer) when is_binary(answer) do
    isCorrect = Enum.any?(block.saq_answer_choices, fn choice ->
       choice["text"] == answer
     end)
    {:ok, {isCorrect, isCorrect}}
  end

  def test_block_type("fc", %Block{} = _block, _answer) do
    # Flash Card blocks are always "correct" when tested
    {:ok, {true, true}}
  end

  def test_block_type("fibq", %Block{} = _block, answer_list) do
    # answer_list is expected to be [%{answer: "blue", input_idx: 0, value: "actual_answer"}]

    graded_answers = Enum.map(answer_list, fn li ->
      Map.put(li, :correct, li["answer"] == li["value"])
    end)

    is_block_correct = Enum.all?(graded_answers, fn answer -> answer.correct end)

    {:ok, {is_block_correct, graded_answers}}
  end
end
