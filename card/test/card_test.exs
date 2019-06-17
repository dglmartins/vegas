defmodule CardTest do
  use ExUnit.Case
  doctest Card

  test "creates a card" do
    assert Card.new(2, :spades) == %Card{rank: 2, suit: :spades}
  end
end
