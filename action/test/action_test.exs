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

  test "does not bet out of :action status" do
    table_state = @table_state |> Action.place_bet(1, 20)
    assert table_state.seat_map[1].chip_count == 200
    assert table_state.last_to_act == 1
  end

  test "does not bet out of turn" do
    table_state =
      %{@table_state | status: :action}
      |> Action.place_bet(1, 20)

    assert table_state.seat_map[1].chip_count == 200
    assert table_state.last_to_act == 1
  end

  test "attempt to bet less than pre_action_min_bet is increased to min_bet" do
    table_state =
      %{@table_state | status: :action}
      |> Action.place_bet(3, 10)

    assert table_state.seat_map[3].chip_count == 180
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 20
    assert table_state.last_to_act == 1
  end

  test "goes all in if betting entire stack or trying to bet more that entire stack " do
    table_state =
      %{@table_state | status: :action}
      |> Action.place_bet(3, 200)

    assert table_state.seat_map[3].chip_count == 0
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 200
    assert table_state.seat_map[3].status == :all_in

    assert table_state.last_to_act == 1

    table_state =
      %{@table_state | status: :action}
      |> Action.place_bet(3, 220)

    assert table_state.seat_map[3].chip_count == 0
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 200
    assert table_state.seat_map[3].status == :all_in

    assert table_state.last_to_act == 1
  end
end
