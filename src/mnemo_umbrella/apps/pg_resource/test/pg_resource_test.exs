defmodule PgResourceTest do
  use ExUnit.Case
  doctest PgResource

  test "greets the world" do
    assert PgResource.hello() == :world
  end
end
