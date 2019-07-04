defmodule Action.Helpers do
  @seat_with_action_accepted_status [:active]
  def check_end_action_after_check_or_call(
        %{seat_with_action: seat, last_to_act: seat} = table_state
      ) do
    %{
      table_state
      | status: :action_round_ended
    }
  end

  def check_end_action_after_check_or_call(
        %{seat_with_action: seat, seat_map: seat_map} = table_state
      ) do
    seat_with_action =
      SeatHelpers.get_next_taken_seat(seat, seat_map, @seat_with_action_accepted_status)

    %{table_state | seat_with_action: seat_with_action}
  end

  def check_end_action_after_antes_blinds(%{seat_map: seat_map, status: status} = table_state)
      when status in [:posting_antes, :posting_blinds] do
    number_of_active_players =
      seat_map
      |> Enum.filter(fn {_seat, player} -> player.status == :active end)
      |> Enum.count()

    check_end_action(table_state, number_of_active_players)
  end

  def check_end_action_after_raise(%{seat_with_action: :no_other_seats} = table_state) do
    %{
      table_state
      | status: :action_round_ended
    }
  end

  def check_end_action_after_raise(table_state) do
    table_state
  end

  def check_end_action(
        table_state,
        number_of_active_players
      )
      when number_of_active_players <= 1 do
    %{
      table_state
      | status: :action_round_ended
    }
  end

  def check_end_action(
        %{status: :posting_antes} = table_state,
        _number_of_active_players
      ) do
    %{
      table_state
      | status: :posting_blinds
    }
  end

  def check_end_action(
        %{status: :posting_blinds} = table_state,
        _number_of_active_players
      ) do
    %{
      table_state
      | status: :action_opened
    }
  end
end
