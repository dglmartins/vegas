defmodule FunctionsTest do
  use ExUnit.Case
  doctest Deck.Functions

  alias Deck.Functions

  test "creates a deck with 52 cards" do
    deck = Functions.new()

    assert Enum.count(deck) == 52
  end

  test "creates 4 of each rank, one of each suit" do
    deck = Functions.new()

    for rank_check <- 2..14 do
      assert Enum.count(deck, fn %{rank: rank} -> rank == rank_check end) == 4
      filtered_rank = Enum.filter(deck, fn %{rank: rank} -> rank == rank_check end)

      for suit_check <- [:hearts, :clubs, :diamonds, :spades] do
        assert Enum.count(filtered_rank, fn %{suit: suit} -> suit == suit_check end) == 1
      end
    end
  end
end
