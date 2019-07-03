defmodule ActionTest do
  use ExUnit.Case
  doctest Action

  @seat_map %{
    1 => %Player{
      cards: [
        %Card{rank: 7, show: false, suit: :hearts},
        %Card{rank: 11, show: false, suit: :spades}
      ],
      chip_count: 190,
      chips_to_pot_current_bet_round: 0,
      name: "Danilo",
      status: :active
    },
    3 => %Player{
      cards: [
        %Card{rank: 9, show: false, suit: :diamonds},
        %Card{rank: 7, show: false, suit: :spades}
      ],
      chip_count: 210,
      chips_to_pot_current_bet_round: 0,
      name: "Paula",
      status: :active
    },
    7 => %Player{
      cards: [
        %Card{rank: 7, show: false, suit: :diamonds},
        %Card{rank: 11, show: false, suit: :diamonds}
      ],
      chip_count: 250,
      chips_to_pot_current_bet_round: 0,
      name: "Michel",
      status: :active
    }
  }

  @table_state %{
    dealer_seat: 3,
    status: :posting_blinds_antes,
    pre_action_min_bet: 20,
    ante: 5,
    community_cards: [],
    seat_with_action: 3,
    last_to_act: 1,
    seat_map: @seat_map,
    sb_seat: 7,
    bb_seat: 1,
    bet_to_call: 0,
    min_raise: 20
  }

  test "post_antes, post_blinds, raise, raise, raise all in, call, call" do
    table_state =
      @table_state
      |> Action.post_antes()

    assert table_state.seat_map[1].chip_count == 185
    assert table_state.seat_map[3].chip_count == 205
    assert table_state.seat_map[7].chip_count == 245

    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 5

    assert table_state.bet_to_call == 5
    assert table_state.min_raise == 20

    table_state =
      table_state
      |> Action.post_blinds()

    assert table_state.seat_map[1].chip_count == 165
    assert table_state.seat_map[3].chip_count == 205
    assert table_state.seat_map[7].chip_count == 235

    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 25
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 15

    assert table_state.bet_to_call == 25
    assert table_state.min_raise == 20
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 3

    table_state =
      table_state
      |> Action.raise_bet(3, 50)

    #
    assert table_state.seat_map[3].chip_count == 135
    assert table_state.seat_map[3].status == :active
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 75
    assert table_state.bet_to_call == 75
    assert table_state.min_raise == 50
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 7

    table_state =
      table_state
      |> Action.raise_bet(7, 100)

    assert table_state.seat_map[7].chip_count == 75
    assert table_state.seat_map[7].status == :active
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 175
    assert table_state.bet_to_call == 175
    assert table_state.min_raise == 100
    assert table_state.last_to_act == 3
    assert table_state.seat_with_action == 1

    table_state =
      table_state
      |> Action.raise_bet(1, 15)

    assert table_state.seat_map[1].chip_count == 0
    assert table_state.seat_map[1].status == :all_in
    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 190
    assert table_state.bet_to_call == 190
    assert table_state.min_raise == 100
    assert table_state.last_to_act == 7
    assert table_state.seat_with_action == 3

    table_state =
      table_state
      |> Action.raise_bet(3, 20)

    assert table_state.seat_map[3].chip_count == 0
    assert table_state.seat_map[3].status == :all_in
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 210
    assert table_state.bet_to_call == 210
    assert table_state.min_raise == 100
    assert table_state.last_to_act == 7
    assert table_state.seat_with_action == 7

    table_state =
      table_state
      |> Action.place_call(7)

    assert table_state.seat_map[7].chip_count == 40
    assert table_state.seat_map[7].status == :active
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 210
    assert table_state.bet_to_call == 210
    assert table_state.min_raise == 100
    assert table_state.status == :action_round_ended
  end
end
