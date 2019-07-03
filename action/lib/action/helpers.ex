defmodule Action.Helpers do
  def check_end_action(
        %{seat_with_action: seat, last_to_act: seat, dealer_seat: dealer_seat, seat_map: seat_map} =
          table_state
      ) do
    seat_with_action = SeatHelpers.get_next_taken_seat(dealer_seat, seat_map)

    %{
      table_state
      | status: :action_round_ended,
        seat_with_action: seat_with_action,
        last_to_act: dealer_seat
    }
  end

  def check_end_action(
        %{seat_with_action: seat, seat_map: seat_map, last_to_act: last_to_act} = table_state
      ) do
    is_last_to_act_all_in? = seat_map[last_to_act].status == :all_in
    check_end_action(table_state, is_last_to_act_all_in?)
  end

  def check_end_action(
        %{seat_with_action: seat, seat_map: seat_map} = table_state,
        false = _is_last_to_act_all_in?
      ) do
    seat_with_action = SeatHelpers.get_next_taken_seat(seat, seat_map)
    %{table_state | seat_with_action: seat_with_action}
  end

  def check_end_action(
        %{seat_with_action: seat, seat_map: seat_map, last_to_act: last_to_act} = table_state,
        true = _is_last_to_act_all_in?
      ) do
    last_to_act = SeatHelpers.get_previous_taken_seat(last_to_act, seat_map)
    table_state = %{table_state | last_to_act: last_to_act}
    check_end_action(table_state)
  end
end
