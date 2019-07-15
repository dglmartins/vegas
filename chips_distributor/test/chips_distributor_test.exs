defmodule ChipsDistributorTest do
  use ExUnit.Case
  doctest ChipsDistributor

  @seat_map %{
    1 => %{
      cards: [
        %Card{rank: 7, show: false, suit: :hearts},
        %Card{rank: 7, show: false, suit: :spades}
      ],
      chip_count: 0,
      chips_to_pot_current_bet_round: 0,
      name: "Danilo",
      status: :all_in,
      hand_rank_at_showdown: nil
    },
    2 => %{
      cards: [
        %Card{rank: 13, show: false, suit: :clubs},
        %Card{rank: 13, show: false, suit: :hearts}
      ],
      chip_count: 0,
      chips_to_pot_current_bet_round: 0,
      name: "Paula",
      status: :all_in,
      hand_rank_at_showdown: nil
    },
    3 => %{
      cards: [
        %Card{rank: 14, show: false, suit: :clubs},
        %Card{rank: 14, show: false, suit: :hearts}
      ],
      chip_count: 0,
      chips_to_pot_current_bet_round: 0,
      name: "Paula",
      status: :all_in,
      hand_rank_at_showdown: nil
    },
    7 => %{
      cards: [
        %Card{rank: 14, show: false, suit: :diamonds},
        %Card{rank: 13, show: false, suit: :spades}
      ],
      chip_count: 0,
      chips_to_pot_current_bet_round: 0,
      name: "Michel",
      status: :all_in,
      hand_rank_at_showdown: nil
    },
    9 => %{
      cards: [
        %Card{rank: 7, show: false, suit: :hearts},
        %Card{rank: 2, show: false, suit: :clubs}
      ],
      chip_count: 260,
      chips_to_pot_current_bet_round: 0,
      name: "Renato",
      status: :active,
      hand_rank_at_showdown: nil
    },
    10 => %{
      cards: [
        %Card{rank: 7, show: false, suit: :clubs},
        %Card{rank: 9, show: false, suit: :spades}
      ],
      chip_count: 250,
      chips_to_pot_current_bet_round: 0,
      name: "Renato",
      status: :active,
      hand_rank_at_showdown: nil
    }
  }

  @seat_map_two %{
    1 => %{
      cards: [
        %{rank: 7, show: false, suit: :hearts},
        %{rank: 11, show: false, suit: :spades}
      ],
      chip_count: 60,
      chips_to_pot_current_bet_round: 10,
      name: "Danilo",
      status: :fold,
      hand_rank_at_showdown: nil
    },
    2 => %{
      cards: [
        %{rank: 9, show: false, suit: :diamonds},
        %{rank: 7, show: false, suit: :spades}
      ],
      chip_count: 80,
      chips_to_pot_current_bet_round: 15,
      name: "Paula",
      status: :fold,
      hand_rank_at_showdown: nil
    },
    3 => %{
      cards: [
        %{rank: 9, show: false, suit: :diamonds},
        %{rank: 7, show: false, suit: :spades}
      ],
      chip_count: 90,
      chips_to_pot_current_bet_round: 10,
      name: "Paula",
      status: :fold,
      hand_rank_at_showdown: nil
    },
    7 => %{
      cards: [
        %{rank: 7, show: false, suit: :diamonds},
        %{rank: 11, show: false, suit: :diamonds}
      ],
      chip_count: 100,
      chips_to_pot_current_bet_round: 30,
      name: "Michel",
      status: :fold,
      hand_rank_at_showdown: nil
    },
    9 => %{
      cards: [
        %{rank: 7, show: false, suit: :diamonds},
        %{rank: 11, show: false, suit: :diamonds}
      ],
      chip_count: 250,
      chips_to_pot_current_bet_round: 60,
      name: "Renato",
      status: :active,
      hand_rank_at_showdown: nil
    },
    10 => %{
      cards: [
        %{rank: 7, show: false, suit: :diamonds},
        %{rank: 11, show: false, suit: :diamonds}
      ],
      chip_count: 250,
      chips_to_pot_current_bet_round: 40,
      name: "Renato",
      status: :fold,
      hand_rank_at_showdown: nil
    }
  }

  @table_state %{
    dealer_seat: 3,
    status: :distributing_chips,
    pre_action_min_bet: 20,
    ante: 5,
    community_cards: [
      %Card{rank: 14, show: false, suit: :spades},
      %Card{rank: 13, show: false, suit: :diamonds},
      %Card{rank: 12, show: false, suit: :clubs},
      %Card{rank: 12, show: false, suit: :spades},
      %Card{rank: 7, show: false, suit: :diamonds}
    ],
    seat_with_action: 3,
    last_to_act: 1,
    seat_map: @seat_map,
    sb_seat: 7,
    bb_seat: 1,
    bet_to_call: 50,
    min_raise: 20,
    pots: [
      %Pot{seats: [:all_active], pot_value: 39, winners: [9, 10]},
      %Pot{seats: [:all_active, 1, 3, 2, 7], pot_value: 260, winners: [3]},
      %Pot{seats: [:all_active, 2, 7], pot_value: 20, winners: [2]},
      %Pot{seats: [:all_active, 7], pot_value: 45, winners: [7]}
    ]
  }

  @table_state_two %{
    dealer_seat: 3,
    status: :end_hand_no_showdown,
    pre_action_min_bet: 20,
    ante: 5,
    community_cards: [
      %Card{rank: 14, show: false, suit: :spades},
      %Card{rank: 13, show: false, suit: :diamonds},
      %Card{rank: 12, show: false, suit: :clubs},
      %Card{rank: 12, show: false, suit: :spades},
      %Card{rank: 7, show: false, suit: :diamonds}
    ],
    seat_with_action: 3,
    last_to_act: 1,
    seat_map: @seat_map_two,
    sb_seat: 7,
    bb_seat: 1,
    bet_to_call: 50,
    min_raise: 20,
    pots: [
      %Pot{seats: [:all_active], pot_value: 100, winners: []}
    ]
  }

  test "distributes chips when had a showdown" do
    table_state =
      @table_state
      |> ChipsDistributor.distribute()

    assert table_state.seat_map[1].chip_count == 0
    assert table_state.seat_map[2].chip_count == 20

    assert table_state.seat_map[3].chip_count == 260

    assert table_state.seat_map[7].chip_count == 45

    assert table_state.seat_map[9].chip_count == 279
    assert table_state.seat_map[10].chip_count == 270
  end

  test "distributes when end hand no showdown" do
    table_state =
      @table_state_two
      |> ChipsDistributor.distribute()

    assert table_state.seat_map[1].chip_count == 60
    assert table_state.seat_map[2].chip_count == 80

    assert table_state.seat_map[3].chip_count == 90

    assert table_state.seat_map[7].chip_count == 100

    assert table_state.seat_map[9].chip_count == 350
    assert table_state.seat_map[10].chip_count == 250
  end
end
