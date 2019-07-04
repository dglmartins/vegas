defmodule AntesTest do
  use ExUnit.Case
  doctest Action.Antes

  alias Action.Antes

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

  @seat_map_two %{
    1 => %Player{
      cards: [],
      chip_count: 3,
      chips_to_pot_current_bet_round: 0,
      name: "Danilo",
      status: :active
    },
    3 => %Player{
      cards: [],
      chip_count: 2,
      chips_to_pot_current_bet_round: 0,
      name: "Paula",
      status: :active
    },
    7 => %Player{
      cards: [],
      chip_count: 1,
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

  test "posts antes" do
    table_state =
      @table_state
      |> Antes.post_antes()

    assert table_state.seat_map[1].chip_count == 195
    assert table_state.seat_map[3].chip_count == 175
    assert table_state.seat_map[7].chip_count == 235
    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
  end

  test "posts antes all in" do
    player_four = %Player{
      cards: [],
      chip_count: 5,
      chips_to_pot_current_bet_round: 0,
      name: "Renato",
      status: :active
    }

    seat_map = Map.put(@seat_map, 9, player_four)

    table_state =
      %{@table_state | seat_map: seat_map}
      |> Antes.post_antes()

    assert table_state.seat_map[1].chip_count == 195
    assert table_state.seat_map[3].chip_count == 175
    assert table_state.seat_map[7].chip_count == 235
    assert table_state.seat_map[9].chip_count == 0
    assert table_state.seat_map[9].status == :all_in

    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[9].chips_to_pot_current_bet_round == 5
  end

  test "posts antes all in stack less than ante" do
    player_four = %Player{
      cards: [],
      chip_count: 3,
      chips_to_pot_current_bet_round: 0,
      name: "Renato",
      status: :active
    }

    seat_map = Map.put(@seat_map, 9, player_four)

    table_state =
      %{@table_state | seat_map: seat_map}
      |> Antes.post_antes()

    assert table_state.seat_map[1].chip_count == 195
    assert table_state.seat_map[3].chip_count == 175
    assert table_state.seat_map[7].chip_count == 235
    assert table_state.seat_map[9].chip_count == 0
    assert table_state.seat_map[9].status == :all_in

    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[9].chips_to_pot_current_bet_round == 3
  end

  test "posts antes everyone all in ends round" do
    table_state =
      %{@table_state | seat_map: @seat_map_two}
      |> Antes.post_antes()

    assert table_state.seat_map[1].chip_count == 0
    assert table_state.seat_map[3].chip_count == 0
    assert table_state.seat_map[7].chip_count == 0
    assert table_state.seat_map[1].status == :all_in
    assert table_state.seat_map[3].status == :all_in
    assert table_state.seat_map[7].status == :all_in

    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 3
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 2
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 1
    assert table_state.status == :deal_to_showdown
  end

  test "posts antes everyone but one player in ends round" do
    player_four = %Player{
      cards: [],
      chip_count: 12,
      chips_to_pot_current_bet_round: 0,
      name: "Renato",
      status: :active
    }

    table_state =
      %{@table_state | seat_map: Map.put(@seat_map_two, 4, player_four)}
      |> Antes.post_antes()

    assert table_state.seat_map[1].chip_count == 0
    assert table_state.seat_map[3].chip_count == 0
    assert table_state.seat_map[4].chip_count == 7
    assert table_state.seat_map[7].chip_count == 0

    assert table_state.seat_map[1].status == :all_in
    assert table_state.seat_map[3].status == :all_in
    assert table_state.seat_map[4].status == :active
    assert table_state.seat_map[7].status == :all_in

    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 3
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 2
    assert table_state.seat_map[4].chips_to_pot_current_bet_round == 5
    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 1
    assert table_state.status == :deal_to_showdown
  end
end
