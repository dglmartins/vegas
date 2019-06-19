defmodule PlayTest do
  use ExUnit.Case
  doctest NlHoldemHand.Play

  alias NlHoldemHand.{State, Play}

  @min_bet 10
  @ante 0
  @seat_map_from_table %{
    1 => %Player{cards: [], chip_count: 200, name: "Danilo", status: :active},
    2 => :empty_seat,
    3 => %Player{cards: [], chip_count: 200, name: "Paula", status: :active},
    4 => :empty_seat,
    5 => :empty_seat,
    6 => :empty_seat,
    7 => %Player{cards: [], chip_count: 200, name: "Michel", status: :active},
    8 => :empty_seat,
    9 => :empty_seat,
    10 => :empty_seat
  }
  @table_id "test_table"
  @dealer_seat 3

  test "deals 2 cards to each player" do
    hand_id = generate_hand_id()
    Deck.create_deck(hand_id)

    hand_state =
      State.new(
        hand_id,
        @table_id,
        @min_bet,
        @ante,
        @seat_map_from_table,
        @dealer_seat
      )
      |> Play.deal_hole_cards()

    assert Enum.count(hand_state.seat_map[1].cards) == 2
    assert Enum.count(hand_state.seat_map[3].cards) == 2
    assert Enum.count(hand_state.seat_map[7].cards) == 2

    assert Deck.DeckServer.count_deck(hand_id) == 46
  end

  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end
