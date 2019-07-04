defmodule Action.Check do
  alias Action.Helpers

  def check(
        %{seat_with_action: seat_with_action, status: :action_to_open} = table_state,
        seat
      ) do
    correct_turn? = seat == seat_with_action
    check(table_state, seat, correct_turn?)
  end

  def check(table_state, _seat) do
    IO.puts("Table not expecting check action")
    table_state
  end

  def check(table_state, _seat, false = _correct_turn?) do
    IO.puts("Seat attempting to check out of turn")
    table_state
  end

  def check(table_state, _seat, true = _correct_turn?) do
    table_state
    |> Helpers.check_end_action_after_check_call()
  end
end
