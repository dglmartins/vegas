defmodule BlindsTest do
  use ExUnit.Case
  doctest Action.Blinds

  alias Action.{Blinds}

  @seat_map %{
    1 => %Player{
      cards: [],
      chip_count: 195,
      chips_to_pot_current_bet_round: 5,
      name: "Danilo",
      status: :active
    },
    3 => %Player{
      cards: [],
      chip_count: 175,
      chips_to_pot_current_bet_round: 5,
      name: "Paula",
      status: :active
    },
    7 => %Player{
      cards: [],
      chip_count: 235,
      chips_to_pot_current_bet_round: 5,
      name: "Michel",
      status: :active
    }
  }

  @table_state %{
    dealer_seat: 3,
    status: :posting_blinds,
    pre_action_min_bet: 20,
    ante: 5,
    community_cards: [],
    seat_with_action: 3,
    last_to_act: 1,
    seat_map: @seat_map,
    sb_seat: 7,
    bb_seat: 1,
    bet_to_call: 5,
    min_raise: 20
  }

  test "posts blinds" do
    table_state =
      @table_state
      |> Blinds.post_blinds()

    assert table_state.seat_map[1].chip_count == 175
    assert table_state.seat_map[3].chip_count == 175
    assert table_state.seat_map[7].chip_count == 225
    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 25
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 15
    assert table_state.status == :action_opened
    assert table_state.bet_to_call == 25
  end

  test "posts blinds goes all in" do
    player_one = %Player{
      cards: [],
      chip_count: 20,
      chips_to_pot_current_bet_round: 5,
      name: "Danilo",
      status: :active
    }

    seat_map = Map.put(@seat_map, 1, player_one)

    table_state =
      %{@table_state | seat_map: seat_map}
      |> Blinds.post_blinds()

    assert table_state.seat_map[1].chip_count == 0
    assert table_state.seat_map[3].chip_count == 175
    assert table_state.seat_map[7].chip_count == 225
    assert table_state.seat_map[1].status == :all_in

    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 25
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 15
    assert table_state.status == :action_opened
    assert table_state.bet_to_call == 25
  end

  test "posts antes all in stack less than blind" do
    player_one = %Player{
      cards: [],
      chip_count: 3,
      chips_to_pot_current_bet_round: 5,
      name: "Danilo",
      status: :active
    }

    seat_map = Map.put(@seat_map, 1, player_one)

    table_state =
      %{@table_state | seat_map: seat_map}
      |> Blinds.post_blinds()

    assert table_state.seat_map[1].chip_count == 0
    assert table_state.seat_map[3].chip_count == 175
    assert table_state.seat_map[7].chip_count == 225
    assert table_state.seat_map[1].status == :all_in

    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 8
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 15
    assert table_state.status == :action_opened
    assert table_state.bet_to_call == 25
  end
end
