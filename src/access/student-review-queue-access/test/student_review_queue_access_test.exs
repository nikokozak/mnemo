defmodule StudentReviewQueueAccessTest do
  use ExUnit.Case
  doctest StudentReviewQueueAccess

  test "greets the world" do
    assert StudentReviewQueueAccess.hello() == :world
  end
end
