defmodule NlHoldemHand.SeatSetup do
  @sb_bb_accepted_status [:active, :all_in]
  @first_to_act_accepted_status [:active]

  def get_sb_seat(dealer_seat, seat_map) do
    is_heads_up? = Enum.count(seat_map) == 2
    get_sb_seat(dealer_seat, seat_map, is_heads_up?)
  end

  def get_sb_seat(dealer_seat, _seat_map, true = _is_heads_up?) do
    dealer_seat
  end

  def get_sb_seat(dealer_seat, seat_map, false = _is_heads_up?) do
    dealer_seat
    |> SeatHelpers.get_next_taken_seat(seat_map, @sb_bb_accepted_status)
  end

  def get_bb_seat(dealer_seat, seat_map) do
    dealer_seat
    |> get_sb_seat(seat_map)
    |> SeatHelpers.get_next_taken_seat(seat_map, @sb_bb_accepted_status)
  end

  def get_first_to_act_first_round(dealer_seat, seat_map) do
    dealer_seat
    |> get_bb_seat(seat_map)
    |> SeatHelpers.get_next_taken_seat(seat_map, @first_to_act_accepted_status)
  end

  def get_last_to_act_first_round(dealer_seat, seat_map) do
    dealer_seat
    |> get_first_to_act_first_round(seat_map)
    |> SeatHelpers.get_previous_taken_seat(seat_map, @first_to_act_accepted_status)
  end
end
