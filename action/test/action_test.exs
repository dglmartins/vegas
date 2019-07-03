defmodule ActionTest do
  use ExUnit.Case
  doctest Action

  @seat_map %{
    1 => %Player{
      cards: [
        %Card{rank: 7, show: false, suit: :hearts},
        %Card{rank: 11, show: false, suit: :spades}
      ],
      chip_count: 200,
      chips_to_pot_current_bet_round: 0,
      name: "Danilo",
      status: :active
    },
    3 => %Player{
      cards: [
        %Card{rank: 9, show: false, suit: :diamonds},
        %Card{rank: 7, show: false, suit: :spades}
      ],
      chip_count: 200,
      chips_to_pot_current_bet_round: 0,
      name: "Paula",
      status: :active
    },
    7 => %Player{
      cards: [
        %Card{rank: 7, show: false, suit: :diamonds},
        %Card{rank: 11, show: false, suit: :diamonds}
      ],
      chip_count: 200,
      chips_to_pot_current_bet_round: 0,
      name: "Michel",
      status: :active
    }
  }

  @table_state %{
    dealer_seat: 3,
    status: :waiting,
    pre_action_min_bet: 20,
    ante: 0,
    community_cards: [],
    seat_with_action: 3,
    last_to_act: 1,
    seat_map: @seat_map,
    sb_seat: 7,
    bb_seat: 1,
    bet_to_call: 20,
    min_raise: 20
  }

  test "raise, raise, raise all in, call, call" do
    player_seven = %Player{
      cards: [
        %Card{rank: 7, show: false, suit: :diamonds},
        %Card{rank: 11, show: false, suit: :diamonds}
      ],
      chip_count: 190,
      chips_to_pot_current_bet_round: 10,
      name: "Michel",
      status: :active
    }

    player_one = %Player{
      cards: [
        %Card{rank: 7, show: false, suit: :hearts},
        %Card{rank: 11, show: false, suit: :spades}
      ],
      chip_count: 180,
      chips_to_pot_current_bet_round: 20,
      name: "Danilo",
      status: :active
    }

    seat_map =
      @seat_map
      |> Map.put(7, player_seven)
      |> Map.put(1, player_one)

    table_state =
      %{@table_state | status: :action_opened, seat_map: seat_map}
      |> Action.raise_bet(3, 30)

    assert table_state.seat_map[3].chip_count == 150
    assert table_state.seat_map[3].status == :active
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 50
    assert table_state.bet_to_call == 50
    assert table_state.min_raise == 30
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 7

    table_state =
      table_state
      |> Action.raise_bet(7, 50)

    assert table_state.seat_map[7].chip_count == 100
    assert table_state.seat_map[7].status == :active
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 100
    assert table_state.bet_to_call == 100
    assert table_state.min_raise == 50
    assert table_state.last_to_act == 3
    assert table_state.seat_with_action == 1

    table_state =
      table_state
      |> Action.raise_bet(1, 100)

    assert table_state.seat_map[1].chip_count == 0
    assert table_state.seat_map[1].status == :all_in
    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 200
    assert table_state.bet_to_call == 200
    assert table_state.min_raise == 100
    assert table_state.last_to_act == 7
    assert table_state.seat_with_action == 3

    table_state =
      table_state
      |> Action.place_call(3)

    assert table_state.seat_map[3].chip_count == 0
    assert table_state.seat_map[3].status == :all_in
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 200
    assert table_state.bet_to_call == 200
    assert table_state.min_raise == 100
    assert table_state.last_to_act == 7
    assert table_state.seat_with_action == 7

    table_state =
      table_state
      |> Action.place_call(7)

    assert table_state.seat_map[3].chip_count == 0
    assert table_state.seat_map[3].status == :all_in
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 200
    assert table_state.bet_to_call == 200
    assert table_state.min_raise == 100
    assert table_state.last_to_act == 3
    assert table_state.seat_with_action == 7
    assert table_state.status == :action_round_ended
  end
end
