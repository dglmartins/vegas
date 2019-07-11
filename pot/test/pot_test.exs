defmodule PotTest do
  use ExUnit.Case
  doctest Pot

  @seat_map %{
    1 => %{
      cards: [
        %{rank: 7, show: false, suit: :hearts},
        %{rank: 11, show: false, suit: :spades}
      ],
      chip_count: 50,
      chips_to_pot_current_bet_round: 100,
      name: "Danilo",
      status: :active
    },
    3 => %{
      cards: [
        %{rank: 9, show: false, suit: :diamonds},
        %{rank: 7, show: false, suit: :spades}
      ],
      chip_count: 80,
      chips_to_pot_current_bet_round: 50,
      name: "Paula",
      status: :active
    },
    7 => %{
      cards: [
        %{rank: 7, show: false, suit: :diamonds},
        %{rank: 11, show: false, suit: :diamonds}
      ],
      chip_count: 250,
      chips_to_pot_current_bet_round: 50,
      name: "Michel",
      status: :active
    },
    9 => %{
      cards: [
        %{rank: 7, show: false, suit: :diamonds},
        %{rank: 11, show: false, suit: :diamonds}
      ],
      chip_count: 250,
      chips_to_pot_current_bet_round: 60,
      name: "Renato",
      status: :active
    }
  }

  @seat_map_two %{
    1 => %{
      cards: [
        %{rank: 7, show: false, suit: :hearts},
        %{rank: 11, show: false, suit: :spades}
      ],
      chip_count: 0,
      chips_to_pot_current_bet_round: 10,
      name: "Danilo",
      status: :all_in
    },
    2 => %{
      cards: [
        %{rank: 9, show: false, suit: :diamonds},
        %{rank: 7, show: false, suit: :spades}
      ],
      chip_count: 0,
      chips_to_pot_current_bet_round: 15,
      name: "Paula",
      status: :all_in
    },
    3 => %{
      cards: [
        %{rank: 9, show: false, suit: :diamonds},
        %{rank: 7, show: false, suit: :spades}
      ],
      chip_count: 0,
      chips_to_pot_current_bet_round: 10,
      name: "Paula",
      status: :all_in
    },
    7 => %{
      cards: [
        %{rank: 7, show: false, suit: :diamonds},
        %{rank: 11, show: false, suit: :diamonds}
      ],
      chip_count: 0,
      chips_to_pot_current_bet_round: 30,
      name: "Michel",
      status: :all_in
    },
    9 => %{
      cards: [
        %{rank: 7, show: false, suit: :diamonds},
        %{rank: 11, show: false, suit: :diamonds}
      ],
      chip_count: 250,
      chips_to_pot_current_bet_round: 60,
      name: "Renato",
      status: :active
    },
    10 => %{
      cards: [
        %{rank: 7, show: false, suit: :diamonds},
        %{rank: 11, show: false, suit: :diamonds}
      ],
      chip_count: 250,
      chips_to_pot_current_bet_round: 50,
      name: "Renato",
      status: :active
    }
  }

  @table_state %{
    dealer_seat: 3,
    status: :action_round_ended,
    pre_action_min_bet: 20,
    ante: 5,
    community_cards: [],
    seat_with_action: 3,
    last_to_act: 1,
    seat_map: @seat_map,
    sb_seat: 7,
    bb_seat: 1,
    bet_to_call: 50,
    min_raise: 20,
    pots: [%{seats: [:all_active], pot_value: 200}]
  }

  test "does not reset pots and bets when out of status" do
    table_state = Pot.reset_pots_bets(@table_state)
    assert table_state.pots == [%{seats: [:all_active], pot_value: 200}]
    assert table_state.bet_to_call == 50
  end

  test "resets pots and bets " do
    table_state = %{@table_state | status: :starting_hand}
    table_state = Pot.reset_pots_bets(table_state)
    assert table_state.pots == [%{seats: [:all_active], pot_value: 0}]
    assert table_state.bet_to_call == 0
    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 0
  end

  test "distributes to pot, returns excess chips, when no one is all in" do
    table_state = Pot.distribute_to_pots(@table_state)
    assert table_state.pots == [%{seats: [:all_active], pot_value: 400}]
    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 0
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 0

    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 0

    assert table_state.seat_map[9].chips_to_pot_current_bet_round == 0
    assert table_state.seat_map[1].chip_count == 100
    assert table_state.seat_map[3].chip_count == 80

    assert table_state.seat_map[7].chip_count == 250

    assert table_state.seat_map[9].chip_count == 260
  end

  test "distributes to pots, returns excess chips, creates several side pots properly when several players all in" do
    table_state = %{@table_state | seat_map: @seat_map_two}
    table_state = Pot.distribute_to_pots(table_state)

    assert table_state.pots == [
             %{seats: [:all_active], pot_value: 40},
             %{seats: [:all_active, 1, 3, 2, 7], pot_value: 260},
             %{seats: [:all_active, 2, 7], pot_value: 20},
             %{seats: [:all_active, 7], pot_value: 45}
           ]

    assert table_state.seat_map[1].chips_to_pot_current_bet_round == 0
    assert table_state.seat_map[3].chips_to_pot_current_bet_round == 0

    assert table_state.seat_map[7].chips_to_pot_current_bet_round == 0

    assert table_state.seat_map[9].chips_to_pot_current_bet_round == 0
    assert table_state.seat_map[10].chips_to_pot_current_bet_round == 0

    assert table_state.seat_map[1].chip_count == 0
    assert table_state.seat_map[3].chip_count == 0

    assert table_state.seat_map[7].chip_count == 0

    assert table_state.seat_map[9].chip_count == 260
    assert table_state.seat_map[10].chip_count == 250
  end
end
