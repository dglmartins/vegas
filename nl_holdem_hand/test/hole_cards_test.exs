defmodule HoleCardsTest do
  use ExUnit.Case
  doctest NlHoldemHand.Dealer.HoleCards

  alias NlHoldemHand.{Setup, Dealer}

  @seat_map %{
    1 => Player.new("Danilo", 200),
    3 => Player.new("Paula", 200),
    7 => Player.new("Michel", 200)
  }

  @table_state %{
    dealer_seat: 3,
    status: :waiting,
    hand_history: [],
    pre_action_min_bet: 20,
    ante: 0,
    game_type: :nl_holdem,
    pots: [],
    deck: nil,
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
      |> Dealer.HoleCards.deal_hole_cards()

    assert Enum.count(table_state.seat_map[1].cards) == 2
    assert Enum.count(table_state.seat_map[3].cards) == 2
    assert Enum.count(table_state.seat_map[7].cards) == 2

    assert Enum.count(table_state.deck) == 46
  end

  test "does not deals hole cards when status is not :dealing_hole_cards" do
    hand_id = generate_hand_id()

    table_state = %{Setup.new(@table_state, hand_id) | status: :waiting}

    table_state |> Dealer.HoleCards.deal_hole_cards()

    assert table_state.seat_map[1].cards == []
    assert table_state.seat_map[3].cards == []
    assert table_state.seat_map[7].cards == []

    assert Enum.count(table_state.deck) == 52
  end

  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end
