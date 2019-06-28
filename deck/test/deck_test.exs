defmodule DeckTest do
  use ExUnit.Case
  doctest Deck

  test "new returns a deck" do
    deck = Deck.new()

    assert Enum.count(deck) == 52
  end

  test "creates 4 of each rank, one of each suit" do
    deck = Deck.new()

    for rank_check <- 2..14 do
      assert Enum.count(deck, fn %{rank: rank} -> rank == rank_check end) == 4
      filtered_rank = Enum.filter(deck, fn %{rank: rank} -> rank == rank_check end)

      for suit_check <- [:hearts, :clubs, :diamonds, :spades] do
        assert Enum.count(filtered_rank, fn %{suit: suit} -> suit == suit_check end) == 1
      end
    end
  end

  test "deals a card" do
    deck = Deck.new()

    {%Card{rank: rank, suit: suit}, deck} = Deck.deal_card(deck)

    assert Enum.count(deck) == 51

    assert rank in 1..14
    assert suit in [:spades, :hearts, :diamonds, :clubs]
  end
end
