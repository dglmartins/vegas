defmodule PlayerTest do
  use ExUnit.Case
  doctest Player

  test "creates a player" do
    assert Player.new("Danilo", 200) == %Player{name: "Danilo", chip_count: 200, status: :active}
  end
end
