defmodule NlHoldemHand.SeatSetup do
  def get_sb_seat(dealer_seat, seat_map) do
    is_heads_up? = Enum.count(seat_map) == 2
    get_sb_seat(dealer_seat, seat_map, is_heads_up?)
  end

  def get_sb_seat(dealer_seat, _seat_map, true = _is_heads_up?) do
    dealer_seat
  end

  def get_sb_seat(dealer_seat, seat_map, false = _is_heads_up?) do
    dealer_seat
    |> SeatHelpers.get_next_taken_seat(seat_map)
  end

  def get_bb_seat(dealer_seat, seat_map) do
    dealer_seat
    |> get_sb_seat(seat_map)
    |> SeatHelpers.get_next_taken_seat(seat_map)
  end

  def get_first_to_act_first_round(dealer_seat, seat_map) do
    dealer_seat
    |> get_bb_seat(seat_map)
    |> SeatHelpers.get_next_taken_seat(seat_map)
  end
end
