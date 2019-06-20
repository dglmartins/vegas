defmodule StateTest do
  use ExUnit.Case
  doctest NlHoldemHand.State

  alias NlHoldemHand.State

  @min_bet 10
  @ante 0
  @seat_map_from_table %{
    1 => %Player{cards: [], chip_count: 200, name: "Danilo", status: :active},
    2 => :empty_seat,
    3 => %Player{cards: [], chip_count: 200, name: "Paula", status: :active},
    4 => :empty_seat,
    5 => :empty_seat,
    6 => :empty_seat,
    7 => %Player{cards: [], chip_count: 200, name: "Michel", status: :active},
    8 => :empty_seat,
    9 => :empty_seat,
    10 => :empty_seat
  }
  @table_id "test_table"
  @dealer_seat 3

  test "new hand state" do
    hand_id = generate_hand_id()

    assert %State{
             table_id: table_id,
             min_raise: min_raise,
             ante: ante,
             seat_map: seat_map,
             dealer_seat: dealer_seat,
             sb_seat: sb_seat,
             bb_seat: bb_seat,
             last_to_act: last_to_act,
             seat_with_action: seat_with_action,
             bet_to_call: bet_to_call
           } =
             State.new(
               hand_id,
               @table_id,
               @min_bet,
               @ante,
               @seat_map_from_table,
               @dealer_seat
             )

    assert [table_id, min_raise, ante, dealer_seat] == [
             @table_id,
             @min_bet,
             @ante,
             @dealer_seat
           ]

    assert Enum.count(seat_map) == 3
    assert seat_map[1] == %Player{cards: [], chip_count: 200, name: "Danilo", status: :active}
    assert table_id == "test_table"
    assert sb_seat == 7
    assert bb_seat == 1
    assert last_to_act == 1
    assert seat_with_action == @dealer_seat
    assert bet_to_call == @min_bet
  end

  test "player marked as away when leave_hand is called, nothing happens when leave_hand is called on empty seat" do
    hand_id = generate_hand_id()

    hand_state =
      State.new(
        hand_id,
        @table_id,
        @min_bet,
        @ante,
        @seat_map_from_table,
        @dealer_seat
      )
      |> State.leave_hand(1)

    assert hand_state.seat_map[1] == %Player{
             cards: [],
             chip_count: 200,
             name: "Danilo",
             status: :sitting_out
           }

    new_hand_state = hand_state |> State.leave_hand(5)

    assert new_hand_state == hand_state
  end

  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end
