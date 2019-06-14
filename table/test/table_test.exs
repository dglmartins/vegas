defmodule TableTest do
  use ExUnit.Case
  doctest Table

  test "greets the world" do
    assert Table.hello() == :world
  end
end
