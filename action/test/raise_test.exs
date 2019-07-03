defmodule RaiseTest do
  use ExUnit.Case
  doctest Action.Raise

  alias Action.{Raise, Open}

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

  test "does not raise out of when no :action_opened" do
    table_state = @table_state |> Raise.raise_bet(3, 40)
    assert table_state.seat_map[1].chip_count == 200
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 3
  end

  test "does not raise out of turn" do
    table_state =
      %{@table_state | status: :action_opened, bet_to_call: 20} |> Raise.raise_bet(1, 40)

    assert table_state.seat_map[1].chip_count == 200
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 3
  end

  test "attempt to raise less than min_raise is increased to bet_to_call + min_raise" do
    table_state =
      %{@table_state | status: :action_opened, bet_to_call: 20}
      |> Raise.raise_bet(3, 10)

    assert table_state.seat_map[3].chip_count == 160
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 40
    assert table_state.bet_to_call == 40
    assert table_state.min_raise == 20
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 7
  end

  test "Player all in with raise below min_raise, bet to call = all in bet, min_raise unchanged " do
    player_seven = %Player{
      cards: [
        %Card{rank: 7, show: false, suit: :diamonds},
        %Card{rank: 11, show: false, suit: :diamonds}
      ],
      chip_count: 70,
      chips_to_pot_current_bet_round: 10,
      name: "Michel",
      status: :active
    }

    seat_map = Map.put(@seat_map, 7, player_seven)

    table_state =
      %{@table_state | status: :action_to_open, seat_map: seat_map}
      |> Open.open_bet(3, 50)

    assert table_state.seat_map[3].chip_count == 150
    assert table_state.seat_map[3].status == :active
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 50
    assert table_state.bet_to_call == 50
    assert table_state.min_raise == 50
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 7

    table_state =
      table_state
      |> Raise.raise_bet(7, 50)

    assert table_state.seat_map[7].chip_count == 0
    assert table_state.seat_map[7].status == :all_in
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 80
    assert table_state.bet_to_call == 80
    assert table_state.min_raise == 50
    assert table_state.last_to_act == 3
    assert table_state.seat_with_action == 1
  end
end
