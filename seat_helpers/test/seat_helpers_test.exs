defmodule SeatHelpersTest do
  use ExUnit.Case
  doctest SeatHelpers

  @seat_map %{
    1 => %{name: "Danilo", chip_count: 200, cards: [], status: :active},
    3 => %{name: "Paula", chip_count: 200, cards: [], status: :active},
    7 => %{name: "Michel", chip_count: 200, cards: [], status: :active}
  }

  test "gets next seat taken" do
    assert SeatHelpers.get_next_taken_seat(1, @seat_map) == 3
    assert SeatHelpers.get_next_taken_seat(3, @seat_map) == 7
    assert SeatHelpers.get_next_taken_seat(7, @seat_map) == 1
    assert SeatHelpers.get_next_taken_seat(10, @seat_map) == 1
  end
end
