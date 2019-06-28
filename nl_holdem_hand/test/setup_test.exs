defmodule SetupTest do
  use ExUnit.Case
  doctest NlHoldemHand.Setup

  alias NlHoldemHand.{Setup}

  @seat_map %{
    1 => Player.new("Danilo", 200),
    3 => Player.new("Paula", 200),
    7 => Player.new("Michel", 200)
  }

  @seat_map_two %{
    1 => Player.new("Danilo", 200),
    3 => Player.new("Paula", 200)
  }

  @seat_map_three %{
    1 => Player.new("Danilo", 200),
    3 => Player.new("Paula", 200),
    7 => Player.new("Michel", 200),
    9 => Player.new("Renato", 200),
    10 => Player.new("Rodrigo", 200)
  }

  @table_state %{
    dealer_seat: 3,
    status: :waiting,
    hand_history: [],
    pre_action_min_bet: 20,
    ante: 0,
    game_type: :nl_holdem,
    pots: [],
    deck: nil,
    community_cards: [],
    seat_with_action: nil,
    last_to_act: nil,
    seat_map: @seat_map,
    table_id: nil,
    current_hand_id: nil,
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
      bet_to_call: bet_to_call,
      status: status
    } = Setup.new(@table_state, hand_id)

    assert [pre_action_min_bet, ante, dealer_seat] == [20, 0, 3]

    assert Enum.count(seat_map) == 3
    assert seat_map[1] == %Player{cards: [], chip_count: 200, name: "Danilo", status: :active}
    assert sb_seat == 7
    assert bb_seat == 1
    assert last_to_act == 1
    assert seat_with_action == 3
    assert bet_to_call == 20
    assert status == :dealing_hole_cards
  end

  test "new hand with two players" do
    hand_id = generate_hand_id()

    table_state = %{@table_state | seat_map: @seat_map_two}

    %{
      pre_action_min_bet: pre_action_min_bet,
      ante: ante,
      seat_map: seat_map,
      dealer_seat: dealer_seat,
      sb_seat: sb_seat,
      bb_seat: bb_seat,
      last_to_act: last_to_act,
      seat_with_action: seat_with_action,
      bet_to_call: bet_to_call,
      status: status
    } = Setup.new(table_state, hand_id)

    assert [pre_action_min_bet, ante, dealer_seat] == [20, 0, 3]

    assert Enum.count(seat_map) == 2
    assert seat_map[1] == %Player{cards: [], chip_count: 200, name: "Danilo", status: :active}
    assert sb_seat == 3
    assert bb_seat == 1
    assert last_to_act == 1
    assert seat_with_action == 3
    assert bet_to_call == 20
    assert status == :dealing_hole_cards
  end

  test "new hand with five players" do
    hand_id = generate_hand_id()

    table_state = %{@table_state | seat_map: @seat_map_three}

    %{
      pre_action_min_bet: pre_action_min_bet,
      ante: ante,
      seat_map: seat_map,
      dealer_seat: dealer_seat,
      sb_seat: sb_seat,
      bb_seat: bb_seat,
      last_to_act: last_to_act,
      seat_with_action: seat_with_action,
      bet_to_call: bet_to_call,
      status: status
    } = Setup.new(table_state, hand_id)

    assert [pre_action_min_bet, ante, dealer_seat] == [20, 0, 3]

    assert Enum.count(seat_map) == 5
    assert seat_map[1] == %Player{cards: [], chip_count: 200, name: "Danilo", status: :active}
    assert sb_seat == 7
    assert bb_seat == 9
    assert last_to_act == 9
    assert seat_with_action == 10
    assert bet_to_call == 20
    assert status == :dealing_hole_cards
  end

  test "new hand with five players when bb is seat 10" do
    hand_id = generate_hand_id()

    table_state = %{@table_state | seat_map: @seat_map_three, dealer_seat: 10}

    %{
      pre_action_min_bet: pre_action_min_bet,
      ante: ante,
      seat_map: seat_map,
      dealer_seat: dealer_seat,
      sb_seat: sb_seat,
      bb_seat: bb_seat,
      last_to_act: last_to_act,
      seat_with_action: seat_with_action,
      bet_to_call: bet_to_call,
      status: status
    } = Setup.new(table_state, hand_id)

    assert [pre_action_min_bet, ante, dealer_seat] == [20, 0, 10]

    assert Enum.count(seat_map) == 5
    assert seat_map[1] == %Player{cards: [], chip_count: 200, name: "Danilo", status: :active}
    assert sb_seat == 1
    assert bb_seat == 3
    assert last_to_act == 3
    assert seat_with_action == 7
    assert bet_to_call == 20
    assert status == :dealing_hole_cards
  end

  test "no new hand if not enough players" do
    hand_id = generate_hand_id()

    seat_map = %{1 => Player.new("Danilo", 200)}

    table_state =
      %{@table_state | seat_map: seat_map}
      |> Setup.new(hand_id)

    assert table_state.current_hand_id == nil

    assert table_state.seat_map[1] == %Player{
             cards: [],
             chip_count: 200,
             name: "Danilo",
             status: :active
           }

    assert table_state.sb_seat == nil
    assert table_state.bb_seat == nil
    assert table_state.last_to_act == nil
    assert table_state.seat_with_action == nil
    assert table_state.bet_to_call == 20
    assert table_state.status == :waiting
  end

  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end
