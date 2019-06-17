defmodule CardTest do
  use ExUnit.Case
  doctest Card

  test "greets the world" do
    assert Card.hello() == :world
  end
end
