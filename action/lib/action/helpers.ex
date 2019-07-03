defmodule Action.Helpers do
  def check_end_action(
        %{seat_with_action: seat, last_to_act: seat, dealer_seat: dealer_seat, seat_map: seat_map} =
          table_state
      ) do
    %{
      table_state
      | status: :action_round_ended
    }
  end

  def check_end_action(%{seat_with_action: seat, seat_map: seat_map} = table_state) do
    seat_with_action = SeatHelpers.get_next_taken_seat(seat, seat_map)
    %{table_state | seat_with_action: seat_with_action}
  end
end
