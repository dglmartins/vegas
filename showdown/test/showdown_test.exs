defmodule ShowdownTest do
  use ExUnit.Case
  doctest Showdown

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

  @table_state %{
    dealer_seat: 3,
    status: :showdown,
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
      %Pot{seats: [:all_active], pot_value: 40, winners: []},
      %Pot{seats: [:all_active, 1, 3, 2, 7], pot_value: 260, winners: []},
      %Pot{seats: [:all_active, 2, 7], pot_value: 20, winners: []},
      %Pot{seats: [:all_active, 7], pot_value: 45, winners: []}
    ]
  }

  test "replaces :all_active with active seats in pots" do
    table_state =
      IO.inspect(
        @table_state
        |> Showdown.mark_hands_and_pot_winners()
      )

    assert table_state.pots == [
             %Pot{seats: [:all_active], pot_value: 40, winners: [9, 10]},
             %Pot{seats: [:all_active, 1, 3, 2, 7], pot_value: 260, winners: [3]},
             %Pot{seats: [:all_active, 2, 7], pot_value: 20, winners: [2]},
             %Pot{seats: [:all_active, 7], pot_value: 45, winners: [7]}
           ]

    assert table_state.status == :distributing_chips
  end
end
