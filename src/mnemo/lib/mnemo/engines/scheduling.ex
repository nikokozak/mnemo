defmodule Mnemo.Engines.Scheduling do
  # Loosely based on https://en.wikipedia.org/wiki/SuperMemo
  def review_interval(success?, correct_in_a_row, easyness) do
    if success? do
      case correct_in_a_row do
        # Days until next review
        0 -> 1
        1 -> 3
        n -> n * easyness
      end
    else
      # Review immediately
      1
    end
  end

  def easyness(answer_attempts) do
    case answer_attempts do
      1 -> 3
      2 -> 2
      3 -> 1
    end
  end
end
