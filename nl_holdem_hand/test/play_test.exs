defmodule PlayTest do
  use ExUnit.Case
  doctest NlHoldemHand.Play

  alias NlHoldemHand.{Play}

  @seat_map %{
    1 => %{name: "Danilo", chip_count: 200, cards: [], status: :active},
    3 => %{name: "Paula", chip_count: 200, cards: [], status: :active},
    7 => %{name: "Michel", chip_count: 200, cards: [], status: :active}
  }

  @table_state %{
    dealer_seat: 3,
    status: :ready_to_start_hand,
    hand_history: [],
    pre_action_min_bet: 20,
    ante: 0,
    game_type: :nl_holdem,
    pots: [],
    deck: Deck.new(),
    community_cards: [],
    seat_with_action: nil,
    last_to_act: nil,
    seat_map: @seat_map,
    table_id: nil,
    hand_id: nil,
    current_bet_round: nil,
    sb_seat: nil,
    bb_seat: nil,
    bet_to_call: 20
  }

  test "new hand" do
    hand_id = generate_hand_id()

    %{
      pre_action_min_bet: pre_action_min_bet,
      ante: ante,
      seat_map: seat_map,
      dealer_seat: dealer_seat,
      sb_seat: sb_seat,
      bb_seat: bb_seat,
      last_to_act: last_to_act,
      seat_with_action: seat_with_action,
      bet_to_call: bet_to_call
    } =
      Play.new(
        @table_state,
        hand_id
      )

    assert [pre_action_min_bet, ante, dealer_seat] == [
             20,
             0,
             3
           ]

    assert Enum.count(seat_map) == 3
    assert seat_map[1] == %{cards: [], chip_count: 200, name: "Danilo", status: :active}
    assert sb_seat == 7
    assert bb_seat == 1
    assert last_to_act == 1
    assert seat_with_action == 3
    assert bet_to_call == 20
  end

  test "deals 2 cards to each player" do
    hand_id = generate_hand_id()

    table_state =
      Play.new(
        @table_state,
        hand_id
      )
      |> Play.deal_hole_cards()

    assert Enum.count(table_state.seat_map[1].cards) == 2
    assert Enum.count(table_state.seat_map[3].cards) == 2
    assert Enum.count(table_state.seat_map[7].cards) == 2

    assert Enum.count(table_state.deck) == 46
  end

  # test "player marked as away when leave_hand is called, nothing happens when leave_hand is called on empty seat" do
  #   hand_id = generate_hand_id()
  #
  #   hand_state =
  #     State.new(
  #       hand_id,
  #       @table_id,
  #       @min_bet,
  #       @ante,
  #       @seat_map_from_table,
  #       @dealer_seat
  #     )
  #     |> State.leave_hand(1)
  #
  #   assert hand_state.seat_map[1] == %Player{
  #            cards: [],
  #            chip_count: 200,
  #            name: "Danilo",
  #            status: :sitting_out
  #          }
  #
  #   new_hand_state = hand_state |> State.leave_hand(5)
  #
  #   assert new_hand_state == hand_state
  # end
  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end
