defmodule SeatHelpersTest do
  use ExUnit.Case
  doctest SeatHelpers

  @seat_map %{
    1 => %{name: "Danilo", chip_count: 200, cards: [], status: :active},
    3 => %{name: "Paula", chip_count: 200, cards: [], status: :active},
    7 => %{name: "Michel", chip_count: 200, cards: [], status: :active},
    9 => %{name: "Michel", chip_count: 200, cards: [], status: :fold},
    10 => %{name: "Michel", chip_count: 200, cards: [], status: :all_in}
  }

  @seat_map_two %{
    1 => %{name: "Danilo", chip_count: 200, cards: [], status: :all_in},
    3 => %{name: "Paula", chip_count: 200, cards: [], status: :fold},
    7 => %{name: "Michel", chip_count: 200, cards: [], status: :sitting_out}
  }

  @table_state %{
    dealer_seat: nil,
    status: :posting_antes,
    pre_action_min_bet: 20,
    ante: 5,
    community_cards: [],
    seat_with_action: 3,
    last_to_act: 1,
    seat_map: %{},
    sb_seat: 7,
    bb_seat: 1,
    bet_to_call: 0,
    min_raise: 20
  }

  test "gets next seat taken" do
    assert SeatHelpers.get_next_taken_seat(1, @seat_map, [:active]) == 3
    assert SeatHelpers.get_next_taken_seat(3, @seat_map, [:active]) == 7
    assert SeatHelpers.get_next_taken_seat(7, @seat_map, [:active]) == 1
    assert SeatHelpers.get_next_taken_seat(7, @seat_map, [:active, :all_in]) == 10
    assert SeatHelpers.get_next_taken_seat(1, @seat_map, [:fold]) == 9

    assert SeatHelpers.get_next_taken_seat(10, @seat_map, [:active]) == 1
  end

  test "gets previous seat taken" do
    assert SeatHelpers.get_previous_taken_seat(1, @seat_map, [:active]) == 7
    assert SeatHelpers.get_previous_taken_seat(3, @seat_map, [:active]) == 1
    assert SeatHelpers.get_previous_taken_seat(7, @seat_map, [:active]) == 3
    assert SeatHelpers.get_previous_taken_seat(10, @seat_map, [:active]) == 7
    assert SeatHelpers.get_previous_taken_seat(1, @seat_map, [:active, :all_in]) == 10
  end

  test "no active previous seats" do
    assert SeatHelpers.get_previous_taken_seat(1, @seat_map_two, [:active]) == :no_other_seats
  end

  test "no active next seats" do
    assert SeatHelpers.get_next_taken_seat(1, @seat_map_two, [:active]) == :no_other_seats
  end

  test "moves dealer seat, does not move if not integer or if index > 10, does not move if no one sitting" do
    table_state =
      @table_state
      |> SeatHelpers.move_dealer_to_seat(3)

    assert table_state.dealer_seat == nil

    table_state =
      table_state
      |> SeatHelpers.move_dealer_to_seat("not an integer")

    #
    assert table_state.dealer_seat == nil

    table_state =
      table_state
      |> SeatHelpers.move_dealer_to_seat(11)

    assert table_state.dealer_seat == nil

    table_state = %{table_state | seat_map: @seat_map}

    table_state =
      table_state
      |> SeatHelpers.move_dealer_to_seat(1)

    assert table_state.dealer_seat == 1
  end

  test "moves dealer seat to left, next taken seat, moves to one if current index is 10" do
    table_state =
      @table_state
      |> SeatHelpers.move_dealer_to_left()

    assert table_state.dealer_seat == nil

    table_state = %{table_state | seat_map: @seat_map}
    #
    table_state =
      table_state
      |> SeatHelpers.move_dealer_to_seat(1)

    assert table_state.dealer_seat == 1

    table_state =
      table_state
      |> SeatHelpers.move_dealer_to_left()

    assert table_state.dealer_seat == 3

    table_state =
      table_state
      |> SeatHelpers.move_dealer_to_left()

    assert table_state.dealer_seat == 7

    table_state =
      table_state
      |> SeatHelpers.move_dealer_to_left()

    assert table_state.dealer_seat == 1
  end

  test "move left skips not active seat" do
    table_state = %{@table_state | seat_map: @seat_map}

    table_state =
      table_state
      |> SeatHelpers.move_dealer_to_seat(7)

    assert table_state.dealer_seat == 7

    table_state =
      table_state
      |> SeatHelpers.move_dealer_to_left()

    assert table_state.dealer_seat == 1
  end
end
