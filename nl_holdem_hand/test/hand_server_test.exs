defmodule HandServerTest do
  use ExUnit.Case
  doctest NlHoldemHand.HandServer

  alias NlHoldemHand.{Play, State, HandServer}

  @min_bet 10
  @ante 0
  @seat_map %{
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

  test "spawning a hand server process" do
    hand_id = generate_hand_id()

    assert {:ok, _pid} =
             HandServer.start_link(hand_id, @table_id, @min_bet, @ante, @seat_map, @dealer_seat)
  end

  test "a hand process is registered under a unique hand_id and cannot be restarted" do
    hand_id = generate_hand_id()

    assert {:ok, _pid} =
             HandServer.start_link(hand_id, @table_id, @min_bet, @ante, @seat_map, @dealer_seat)

    assert {:error, {:already_started, _pid}} =
             HandServer.start_link(hand_id, @table_id, @min_bet, @ante, @seat_map, @dealer_seat)
  end

  test "hand server deals a hole card" do
    hand_id = generate_hand_id()

    {:ok, _pid} =
      HandServer.start_link(hand_id, @table_id, @min_bet, @ante, @seat_map, @dealer_seat)

    card = Card.new(2, :spades)
    seat = 3

    assert :ok = HandServer.deal_hole_card({hand_id, card, seat})
  end

  describe "ets" do
    test "stores initial hand state in ETS when started" do
      hand_id = generate_hand_id()

      {:ok, _pid} =
        HandServer.start_link(hand_id, @table_id, @min_bet, @ante, @seat_map, @dealer_seat)

      assert [
               {^hand_id,
                %State{
                  min_raise: min_raise,
                  table_id: table_id,
                  sb_seat: sb_seat,
                  bb_seat: bb_seat,
                  last_to_act: last_to_act,
                  seat_with_action: seat_with_action
                }}
             ] = :ets.lookup(:hands_table, hand_id)

      assert min_raise == 10
      assert table_id == "test_table"
      assert sb_seat == 7
      assert bb_seat == 1
      assert last_to_act == 1
      assert seat_with_action == 7
    end

    test "gets the hand initial state from ETS if previously stored, ignores new parameters" do
      hand_id = generate_hand_id()

      state = State.new(hand_id, @table_id, @min_bet, @ante, @seat_map, @dealer_seat)

      seat_map = state.seat_map
      new_dealer_seat = 7

      new_seat_with_action = State.get_next_taken_seat(new_dealer_seat, seat_map)
      new_sb_seat = State.get_next_taken_seat(new_dealer_seat, seat_map)
      new_bb_seat = State.get_bb_seat(new_dealer_seat, seat_map)
      new_last_to_act = State.get_bb_seat(new_dealer_seat, seat_map)

      new_state = %{
        state
        | dealer_seat: new_dealer_seat,
          seat_with_action: new_seat_with_action,
          sb_seat: new_sb_seat,
          bb_seat: new_bb_seat,
          last_to_act: new_last_to_act
      }

      :ets.insert(:hands_table, {hand_id, new_state})

      {:ok, _pid} =
        HandServer.start_link(hand_id, @table_id, @min_bet, @ante, @seat_map, @dealer_seat)

      assert HandServer.get_dealer_seat(hand_id) == 7
    end
  end

  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end
