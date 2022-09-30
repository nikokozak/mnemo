defmodule SubjectAccessTest do
  use ExUnit.Case
  doctest SubjectAccess

  test "greets the world" do
    assert SubjectAccess.hello() == :world
  end
end
