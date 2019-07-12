defmodule StartHandTest do
  use ExUnit.Case
  doctest Dealer.StartHand

  alias Dealer.StartHand

  @min_bet 10
  @ante 0
  @game_type :nl_holdem

  @seat_map %{
    1 => %Player{
      cards: [],
      chip_count: 190,
      chips_to_pot_current_bet_round: 0,
      name: "Danilo",
      status: :active
    },
    3 => %Player{
      cards: [],
      chip_count: 210,
      chips_to_pot_current_bet_round: 0,
      name: "Paula",
      status: :active
    },
    7 => %Player{
      cards: [],
      chip_count: 250,
      chips_to_pot_current_bet_round: 0,
      name: "Michel",
      status: :active
    }
  }

  @table_state %{
    dealer_seat: 3,
    status: :waiting,
    game_type: :nl_holdem,
    pre_action_min_bet: 20,
    ante: 5,
    community_cards: [],
    seat_with_action: nil,
    last_to_act: nil,
    seat_map: @seat_map,
    sb_seat: nil,
    bb_seat: nil,
    bet_to_call: 20,
    min_raise: 20,
    current_hand_id: nil,
    deck: nil
  }

  test "starts a nl_holdem hand" do
    hand_id = generate_hand_id()

    table_state = StartHand.start_hand(@table_state, hand_id)

    assert [table_state.pre_action_min_bet, table_state.ante, table_state.dealer_seat] == [
             20,
             5,
             3
           ]

    assert table_state.sb_seat == 7
    assert table_state.bb_seat == 1
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 3
    assert table_state.status == :starting_hand
  end

  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end
