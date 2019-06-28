defmodule NlHoldemHand.SeatHelpers do
  @max_seats 10

  def get_next_taken_seat(seat_number, seat_map) when seat_number <= @max_seats do
    get_next_taken_seat(seat_number + 1, seat_map, Map.has_key?(seat_map, seat_number + 1))
  end

  def get_next_taken_seat(seat_number, seat_map, _seat_taken?)
      when seat_number == @max_seats + 1 do
    get_next_taken_seat(1, seat_map, Map.has_key?(seat_map, 1))
  end

  def get_next_taken_seat(seat_number, seat_map, false = _seat_taken?) do
    get_next_taken_seat(seat_number + 1, seat_map, Map.has_key?(seat_map, seat_number + 1))
  end

  def get_next_taken_seat(seat_number, _seat_map, true = _seat_taken?) do
    seat_number
  end

  def get_bb_seat(dealer_seat, seat_map) do
    dealer_seat
    |> get_next_taken_seat(seat_map)
    |> get_next_taken_seat(seat_map)
  end

  def get_first_to_act_first_round(dealer_seat, seat_map) do
    dealer_seat
    |> get_bb_seat(seat_map)
    |> get_next_taken_seat(seat_map)
  end
end