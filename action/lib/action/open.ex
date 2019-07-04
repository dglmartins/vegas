defmodule Action.Open do
  @last_to_act_accepted_status [:active]
  @seat_with_action_accepted_status [:active]

  def open_bet(
        %{seat_with_action: seat_with_action, status: :action_to_open} = table_state,
        seat,
        bet_value
      ) do
    correct_turn? = seat == seat_with_action
    open_bet(table_state, seat, bet_value, correct_turn?)
  end

  def open_bet(table_state, _seat, _bet_value) do
    IO.puts("Table not expecting open action")
    table_state
  end

  def open_bet(table_state, _seat, _bet_value, false = _correct_turn?) do
    IO.puts("Seat attempting to bet out of turn")
    table_state
  end

  def open_bet(
        %{seat_map: seat_map, pre_action_min_bet: pre_action_min_bet} = table_state,
        seat,
        bet_value,
        true = _correct_turn?
      )
      when bet_value < pre_action_min_bet do
    player =
      seat_map[seat]
      |> Player.commit_chips_to_pot(pre_action_min_bet)

    last_to_act =
      SeatHelpers.get_previous_taken_seat(seat, seat_map, @last_to_act_accepted_status)

    seat_with_action =
      SeatHelpers.get_next_taken_seat(seat, seat_map, @seat_with_action_accepted_status)

    %{
      table_state
      | seat_map: Map.put(seat_map, seat, player),
        last_to_act: last_to_act,
        bet_to_call: pre_action_min_bet,
        seat_with_action: seat_with_action,
        status: :action_opened
    }
  end

  def open_bet(
        %{seat_map: seat_map} = table_state,
        seat,
        bet_value,
        true = _correct_turn?
      ) do
    player =
      seat_map[seat]
      |> Player.commit_chips_to_pot(bet_value)

    last_to_act =
      SeatHelpers.get_previous_taken_seat(seat, seat_map, @last_to_act_accepted_status)

    seat_with_action =
      SeatHelpers.get_next_taken_seat(seat, seat_map, @seat_with_action_accepted_status)

    %{
      table_state
      | seat_map: Map.put(seat_map, seat, player),
        last_to_act: last_to_act,
        min_raise: bet_value,
        bet_to_call: bet_value,
        seat_with_action: seat_with_action,
        status: :action_opened
    }
  end
end
