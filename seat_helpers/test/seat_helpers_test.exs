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

  test "gets next seat taken" do
    assert SeatHelpers.get_next_taken_seat(1, @seat_map) == 3
    assert SeatHelpers.get_next_taken_seat(3, @seat_map) == 7
    assert SeatHelpers.get_next_taken_seat(7, @seat_map) == 1
    assert SeatHelpers.get_next_taken_seat(10, @seat_map) == 1
  end

  test "gets previous seat taken" do
    assert SeatHelpers.get_previous_taken_seat(1, @seat_map) == 7
    assert SeatHelpers.get_previous_taken_seat(3, @seat_map) == 1
    assert SeatHelpers.get_previous_taken_seat(7, @seat_map) == 3
    assert SeatHelpers.get_previous_taken_seat(10, @seat_map) == 7
  end

  test "no active next seats" do
    assert SeatHelpers.get_previous_taken_seat(1, @seat_map_two) == :no_active_seats
  end
end
