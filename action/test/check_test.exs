defmodule CheckTest do
  use ExUnit.Case
  doctest Action.Check

  alias Action.Check

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
    bet_to_call: 0,
    min_raise: 20
  }

  test "does not check out of :action_to_open status" do
    table_state = @table_state |> Check.check(1)
    assert table_state.seat_map[1].chip_count == 200
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 3
  end

  test "does not check out of turn" do
    table_state = %{@table_state | status: :action_to_open} |> Check.check(1)
    assert table_state.seat_map[1].chip_count == 200
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 3
  end

  test "checks in turn" do
    table_state = %{@table_state | status: :action_to_open} |> Check.check(3)
    assert table_state.seat_map[1].chip_count == 200
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 7
  end

  test "checks ends a round" do
    table_state =
      %{@table_state | status: :action_to_open, last_to_act: 3}
      |> Check.check(3)

    assert table_state.seat_map[1].chip_count == 200

    assert table_state.status == :action_round_ended
  end
end
