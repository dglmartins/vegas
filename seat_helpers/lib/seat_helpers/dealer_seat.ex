defmodule SeatHelpers.DealerSeat do
  @accepted_dealer_status [:active]
  def move_dealer_to_seat(table_state, new_dealer_seat)
      when not is_integer(new_dealer_seat) or new_dealer_seat > 10 or new_dealer_seat < 1 do
    table_state
  end

  def move_dealer_to_seat(%{seat_map: seat_map} = table_state, new_dealer_seat) do
    is_seat_taken? = Map.has_key?(seat_map, new_dealer_seat)
    move_dealer_to_seat(table_state, new_dealer_seat, is_seat_taken?)
  end

  def move_dealer_to_seat(
        %{seat_map: seat_map} = table_state,
        new_dealer_seat,
        true = is_seat_taken?
      ) do
    is_active_seat? = seat_map[new_dealer_seat].status == :active
    move_dealer_to_seat(table_state, new_dealer_seat, is_seat_taken?, is_active_seat?)
  end

  def move_dealer_to_seat(table_state, _new_dealer_seat, false = _is_seat_taken?) do
    IO.puts("No one sitting there")
    table_state
  end

  def move_dealer_to_seat(
        table_state,
        new_dealer_seat,
        true = _is_seat_taken?,
        true = _is_active_seat?
      ) do
    %{table_state | dealer_seat: new_dealer_seat}
  end

  def move_dealer_to_seat(
        table_state,
        _new_dealer_seat,
        _is_seat_taken?,
        false = _is_active_seat?
      ) do
    IO.puts("No active player sitting there")
    table_state
  end

  def move_dealer_to_left(%{dealer_seat: nil} = table_state), do: table_state

  def move_dealer_to_left(%{dealer_seat: dealer_seat, seat_map: seat_map} = table_state) do
    next_seat = SeatHelpers.get_next_taken_seat(dealer_seat, seat_map, @accepted_dealer_status)
    move_dealer_to_left(table_state, next_seat)
  end

  def move_dealer_to_left(
        table_state,
        :no_other_seats
      ) do
    table_state
  end

  def move_dealer_to_left(
        table_state,
        next_seat
      ) do
    %{table_state | dealer_seat: next_seat}
  end
end
