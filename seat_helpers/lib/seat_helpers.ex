defmodule SeatHelpers do
  alias SeatHelpers.{TakenSeat, DealerSeat}

  defdelegate get_next_taken_seat(seat_number, seat_map, status_list), to: TakenSeat
  defdelegate get_previous_taken_seat(seat_number, seat_map, status_list), to: TakenSeat
  defdelegate move_dealer_to_seat(table_state, new_dealer_seat), to: DealerSeat
  defdelegate move_dealer_to_left(table_state), to: DealerSeat

  # @max_seats 10
  #
  # def get_next_taken_seat(seat_number, seat_map, status_list) when seat_number <= @max_seats do
  #   get_next_taken_seat(
  #     seat_number + 1,
  #     seat_map,
  #     Map.has_key?(seat_map, seat_number + 1),
  #     seat_number,
  #     status_list
  #   )
  # end
  #
  # def get_next_taken_seat(seat_number, seat_map, _seat_taken?, starting_seat, status_list)
  #     when seat_number == @max_seats + 1 do
  #   get_next_taken_seat(1, seat_map, Map.has_key?(seat_map, 1), starting_seat, status_list)
  # end
  #
  # def get_next_taken_seat(seat_number, seat_map, false = _seat_taken?, starting_seat, status_list) do
  #   get_next_taken_seat(
  #     seat_number + 1,
  #     seat_map,
  #     Map.has_key?(seat_map, seat_number + 1),
  #     starting_seat,
  #     status_list
  #   )
  # end
  #
  # def get_next_taken_seat(seat_number, _seat_map, _seat_taken?, seat_number, _status_list) do
  #   :no_other_seats
  # end
  #
  # def get_next_taken_seat(seat_number, seat_map, true = seat_taken?, starting_seat, status_list) do
  #   is_active_or_all_in_seat? = seat_map[seat_number].status in status_list
  #
  #   get_next_taken_seat(
  #     seat_number,
  #     seat_map,
  #     seat_taken?,
  #     starting_seat,
  #     status_list,
  #     is_active_or_all_in_seat?
  #   )
  # end
  #
  # def get_next_taken_seat(
  #       seat_number,
  #       _seat_map,
  #       true = _seat_taken?,
  #       _starting_seat,
  #       _status_list,
  #       true = _is_active_or_all_in_seat?
  #     ) do
  #   seat_number
  # end
  #
  # def get_next_taken_seat(
  #       seat_number,
  #       seat_map,
  #       true = _seat_taken?,
  #       starting_seat,
  #       status_list,
  #       false = _is_active_or_all_in_seat?
  #     ) do
  #   get_next_taken_seat(
  #     seat_number + 1,
  #     seat_map,
  #     Map.has_key?(seat_map, seat_number + 1),
  #     starting_seat,
  #     status_list
  #   )
  # end
  #
  # def get_previous_taken_seat(seat_number, seat_map, status_list)
  #     when seat_number <= @max_seats do
  #   get_previous_taken_seat(
  #     seat_number - 1,
  #     seat_map,
  #     Map.has_key?(seat_map, seat_number - 1),
  #     seat_number,
  #     status_list
  #   )
  # end
  #
  # def get_previous_taken_seat(seat_number, seat_map, _seat_taken?, starting_seat, status_list)
  #     when seat_number == 0 do
  #   get_previous_taken_seat(
  #     @max_seats,
  #     seat_map,
  #     Map.has_key?(seat_map, @max_seats),
  #     starting_seat,
  #     status_list
  #   )
  # end
  #
  # def get_previous_taken_seat(
  #       seat_number,
  #       seat_map,
  #       false = _seat_taken?,
  #       starting_seat,
  #       status_list
  #     ) do
  #   get_previous_taken_seat(
  #     seat_number - 1,
  #     seat_map,
  #     Map.has_key?(seat_map, seat_number - 1),
  #     starting_seat,
  #     status_list
  #   )
  # end
  #
  # def get_previous_taken_seat(seat_number, _seat_map, _seat_taken?, seat_number, _status_list) do
  #   :no_other_seats
  # end
  #
  # def get_previous_taken_seat(
  #       seat_number,
  #       seat_map,
  #       true = seat_taken?,
  #       starting_seat,
  #       status_list
  #     ) do
  #   is_active_or_all_in_seat? = seat_map[seat_number].status in status_list
  #
  #   get_previous_taken_seat(
  #     seat_number,
  #     seat_map,
  #     seat_taken?,
  #     starting_seat,
  #     status_list,
  #     is_active_or_all_in_seat?
  #   )
  # end
  #
  # def get_previous_taken_seat(
  #       seat_number,
  #       _seat_map,
  #       true = _seat_taken?,
  #       _starting_seat,
  #       _status_list,
  #       true = _is_active_or_all_in_seat?
  #     ) do
  #   seat_number
  # end
  #
  # def get_previous_taken_seat(
  #       seat_number,
  #       seat_map,
  #       true = _seat_taken?,
  #       starting_seat,
  #       status_list,
  #       false = _is_active_or_all_in_seat?
  #     ) do
  #   get_previous_taken_seat(
  #     seat_number - 1,
  #     seat_map,
  #     Map.has_key?(seat_map, seat_number - 1),
  #     starting_seat,
  #     status_list
  #   )
  # end
end
