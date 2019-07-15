defmodule FoldTest do
  use ExUnit.Case
  doctest Action.Fold

  alias Action.Fold

  @seat_map %{
    1 => %Player{
      cards: [],
      chip_count: 200,
      chips_to_pot_current_bet_round: 0,
      name: "Danilo",
      status: :active
    },
    3 => %Player{
      cards: [],
      chip_count: 180,
      chips_to_pot_current_bet_round: 0,
      name: "Paula",
      status: :active
    },
    7 => %Player{
      cards: [],
      chip_count: 240,
      chips_to_pot_current_bet_round: 0,
      name: "Michel",
      status: :active
    }
  }

  @table_state %{
    dealer_seat: 3,
    status: :posting_antes,
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

  test "does not fold out of status" do
    table_state =
      @table_state
      |> Fold.fold(3)

    assert table_state.seat_map[1].status == :active
    assert table_state.seat_with_action == 3

    # assert table_state.seat_map[3].chip_count == 175
    # assert table_state.seat_map[7].chip_count == 235
    # assert table_state.seat_map[1].chips_to_pot_current_bet_round == 5
    # assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
    # assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
  end

  test "does not fold out of turn" do
    table_state =
      @table_state
      |> Action.post_antes()
      |> Action.post_blinds()
      |> Fold.fold(1)

    assert table_state.seat_map[1].status == :active
    assert table_state.seat_with_action == 3

    assert table_state.seat_map[1].chip_count == 175
    assert table_state.seat_map[3].chip_count == 175
    assert table_state.seat_map[7].chip_count == 225
    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 25
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 15
  end

  test "folds in turn" do
    table_state =
      @table_state
      |> Action.post_antes()
      |> Action.post_blinds()
      |> Fold.fold(3)

    assert table_state.seat_map[3].status == :fold
    assert table_state.seat_with_action == 7

    assert table_state.seat_map[1].chip_count == 175
    assert table_state.seat_map[3].chip_count == 175
    assert table_state.seat_map[7].chip_count == 225
    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 25
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 15
  end

  test "everyone folds to bb ends hand no showdown" do
    table_state =
      @table_state
      |> Action.post_antes()
      |> Action.post_blinds()
      |> Fold.fold(3)
      |> Fold.fold(7)

    assert table_state.seat_map[3].status == :fold
    assert table_state.seat_map[7].status == :fold

    assert table_state.seat_with_action == 1

    assert table_state.status == :distributing_chips
  end
end
