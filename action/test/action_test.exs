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
    bet_to_call: nil,
    min_raise: 20
  }

  test "does not bet out of :action_to_open status" do
    table_state = @table_state |> Action.open_bet(1, 20)
    assert table_state.seat_map[1].chip_count == 200
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 3
  end

  test "does not call out of when no bet_to_call" do
    table_state = @table_state |> Action.place_call(1)
    assert table_state.seat_map[1].chip_count == 200
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 3
  end

  test "does not call out of :action_opened status" do
    table_state = %{@table_state | bet_to_call: 20} |> Action.place_call(1)
    assert table_state.seat_map[1].chip_count == 200
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 3
  end

  test "does not bet out of turn" do
    table_state =
      %{@table_state | status: :action_to_open}
      |> Action.open_bet(1, 20)

    assert table_state.seat_map[1].chip_count == 200
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 3
  end

  test "does not call out of turn" do
    table_state =
      %{@table_state | status: :action_opened, bet_to_call: 20}
      |> Action.place_call(1)

    assert table_state.seat_map[1].chip_count == 200
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 3
  end

  test "attempt to bet less than pre_action_min_bet is increased to min_bet" do
    table_state =
      %{@table_state | status: :action_to_open}
      |> Action.open_bet(3, 10)

    assert table_state.seat_map[3].chip_count == 180
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 20
    assert table_state.bet_to_call == 20
    assert table_state.min_raise == 20
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 7
  end

  test "Player all in with open below min bet: bet to call still min_bet" do
    player_three = %Player{
      cards: [
        %Card{rank: 9, show: false, suit: :diamonds},
        %Card{rank: 7, show: false, suit: :spades}
      ],
      chip_count: 10,
      chips_to_pot_current_bet_round: 0,
      name: "Paula",
      status: :active
    }

    seat_map = Map.put(@seat_map, 3, player_three)

    table_state =
      %{@table_state | status: :action_to_open, seat_map: seat_map}
      |> Action.open_bet(3, 10)

    assert table_state.seat_map[3].chip_count == 0
    assert table_state.seat_map[3].status == :all_in
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 10
    assert table_state.bet_to_call == 20
    assert table_state.min_raise == 20
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 7
  end

  test "open more than pre_action_min_bet increases min_raise" do
    table_state =
      %{@table_state | status: :action_to_open}
      |> Action.open_bet(3, 50)

    assert table_state.seat_map[3].chip_count == 150
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 50
    assert table_state.min_raise == 50
    assert table_state.bet_to_call == 50
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 7
  end

  test "goes all in if betting entire stack or trying to bet more that entire stack " do
    table_state =
      %{@table_state | status: :action_to_open}
      |> Action.open_bet(3, 200)

    assert table_state.seat_map[3].chip_count == 0
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 200
    assert table_state.seat_map[3].status == :all_in
    assert table_state.seat_with_action == 7
    assert table_state.last_to_act == 1

    table_state =
      %{@table_state | status: :action_to_open}
      |> Action.open_bet(3, 220)

    assert table_state.seat_map[3].chip_count == 0
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 200
    assert table_state.seat_map[3].status == :all_in
    assert table_state.seat_with_action == 7
    assert table_state.last_to_act == 1
  end

  test "calls a bet" do
    table_state =
      %{@table_state | status: :action_opened, bet_to_call: 20}
      |> Action.place_call(3)

    assert table_state.seat_map[3].chip_count == 180
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 20
    assert table_state.seat_map[3].status == :active
    assert table_state.seat_with_action == 7

    assert table_state.last_to_act == 1
  end

  test "goes all in if calling entire stack or trying to call more that entire stack " do
    table_state =
      %{@table_state | status: :action_opened, bet_to_call: 200}
      |> Action.place_call(3)

    assert table_state.seat_map[3].chip_count == 0
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 200
    assert table_state.seat_map[3].status == :all_in
    assert table_state.seat_with_action == 7

    assert table_state.last_to_act == 1

    # calls more than entire stack goes all in

    table_state =
      %{@table_state | status: :action_opened, bet_to_call: 220}
      |> Action.place_call(3)

    assert table_state.seat_map[3].chip_count == 0
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 200
    assert table_state.seat_map[3].status == :all_in
    assert table_state.seat_with_action == 7

    assert table_state.last_to_act == 1
  end
end
