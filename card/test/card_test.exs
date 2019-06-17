defmodule CardTest do
  use ExUnit.Case
  doctest Card

  test "creates a card" do
    card = Card.new(2, :spades)
    assert card == %Card{rank: 2, suit: :spades}
  end

  test "shows card" do
    card = Card.new(2, :spades)
    assert card.show == false

    card = Card.show(card)

    assert card.show == true
  end
end
