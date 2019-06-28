defmodule DealerTest do
  use ExUnit.Case
  doctest NlHoldemHand.Dealer

  alias NlHoldemHand.{Setup, Dealer}

  @seat_map %{
    1 => %{name: "Danilo", chip_count: 200, cards: [], status: :active},
    3 => %{name: "Paula", chip_count: 200, cards: [], status: :active},
    7 => %{name: "Michel", chip_count: 200, cards: [], status: :active}
  }

  @table_state %{
    dealer_seat: 3,
    status: :ready_to_start_hand,
    hand_history: [],
    pre_action_min_bet: 20,
    ante: 0,
    game_type: :nl_holdem,
    pots: [],
    deck: Deck.new(),
    community_cards: [],
    seat_with_action: nil,
    last_to_act: nil,
    seat_map: @seat_map,
    table_id: nil,
    current_hand_id: nil,
    current_bet_round: nil,
    sb_seat: nil,
    bb_seat: nil,
    bet_to_call: 20
  }

  test "deals 2 cards to each player" do
    hand_id = generate_hand_id()

    table_state =
      Setup.new(
        @table_state,
        hand_id
      )
      |> Dealer.deal_hole_cards()

    assert Enum.count(table_state.seat_map[1].cards) == 2
    assert Enum.count(table_state.seat_map[3].cards) == 2
    assert Enum.count(table_state.seat_map[7].cards) == 2

    assert Enum.count(table_state.deck) == 46
  end

  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end
