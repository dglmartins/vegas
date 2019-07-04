defmodule Action.Raise do
  @last_to_act_accepted_status [:active]
  @seat_with_action_accepted_status [:active]

  alias Action.Helpers

  def raise_bet(
        %{seat_with_action: seat_with_action, status: status} = table_state,
        seat,
        bet_value
      )
      when status in [:action_opened, :action_raised] do
    correct_turn? = seat == seat_with_action
    raise_bet(table_state, seat, bet_value, correct_turn?)
  end

  def raise_bet(table_state, _seat, _bet_value) do
    IO.puts("Table not expecting raise action")
    table_state
  end

  def raise_bet(table_state, _seat, _bet_value, false = _correct_turn?) do
    IO.puts("Seat attempting to raise out of turn")
    table_state
  end

  def raise_bet(
        %{seat_map: seat_map, min_raise: min_raise, bet_to_call: bet_to_call} = table_state,
        seat,
        raise_value,
        true = _correct_turn?
      )
      when raise_value < min_raise do
    already_commited = seat_map[seat].chips_to_pot_current_bet_round
    remaining_to_call = bet_to_call - already_commited
    player = seat_map[seat]
    chip_count = player.chip_count
    max_bet_value = min(remaining_to_call + min_raise, chip_count)

    player =
      player
      |> Player.commit_chips_to_pot(max_bet_value)

    last_to_act =
      SeatHelpers.get_previous_taken_seat(seat, seat_map, @last_to_act_accepted_status)

    seat_with_action =
      SeatHelpers.get_next_taken_seat(seat, seat_map, @seat_with_action_accepted_status)

    %{
      table_state
      | seat_map: Map.put(seat_map, seat, player),
        last_to_act: last_to_act,
        bet_to_call: max_bet_value + already_commited,
        seat_with_action: seat_with_action,
        status: :action_raised
    }
    |> Helpers.check_end_action_after_raise()
  end

  def raise_bet(
        %{seat_map: seat_map, bet_to_call: bet_to_call} = table_state,
        seat,
        raise_value,
        true = _correct_turn?
      ) do
    already_commited = seat_map[seat].chips_to_pot_current_bet_round
    remaining_to_call = bet_to_call - already_commited
    player = seat_map[seat]
    chip_count = player.chip_count
    max_bet_value = min(remaining_to_call + raise_value, chip_count)

    player =
      player
      |> Player.commit_chips_to_pot(max_bet_value)

    last_to_act =
      SeatHelpers.get_previous_taken_seat(seat, seat_map, @last_to_act_accepted_status)

    seat_with_action =
      SeatHelpers.get_next_taken_seat(seat, seat_map, @seat_with_action_accepted_status)

    %{
      table_state
      | seat_map: Map.put(seat_map, seat, player),
        last_to_act: last_to_act,
        min_raise: raise_value,
        bet_to_call: max_bet_value + already_commited,
        seat_with_action: seat_with_action,
        status: :action_raised
    }
    |> Helpers.check_end_action_after_raise()
  end
end
