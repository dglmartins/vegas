defmodule Action.Fold do
  alias Action.Helpers

  @accepted_fold_status [:action_to_open, :action_raised, :action_opened]

  def fold(
        %{seat_with_action: seat_with_action, status: status} = table_state,
        seat
      )
      when status in @accepted_fold_status do
    correct_turn? = seat == seat_with_action
    fold(table_state, seat, correct_turn?)
  end

  def fold(table_state, _seat) do
    IO.puts("Table not expecting fold action")
    table_state
  end

  def fold(table_state, _seat, false = _correct_turn?) do
    IO.puts("Seat attempting to fold out of turn")
    table_state
  end

  def fold(%{seat_map: seat_map} = table_state, seat, true = _correct_turn?) do
    player =
      seat_map[seat]
      |> Player.fold()

    %{table_state | seat_map: Map.put(seat_map, seat, player)}
    |> Helpers.check_end_action_after_fold()
  end
end
