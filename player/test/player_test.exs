defmodule PlayerTest do
  use ExUnit.Case
  doctest Player

  test "greets the world" do
    assert Player.hello() == :world
  end
end
