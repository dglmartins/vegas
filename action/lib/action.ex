defmodule Action do
  alias Action.{Open, Call, Check, Raise, Antes, Blinds, Fold}
  defdelegate open_bet(table_state, seat, value), to: Open
  defdelegate place_call(table_state, seat), to: Call
  defdelegate check(table_state, seat), to: Check
  defdelegate raise_bet(table_state, seat, value), to: Raise
  defdelegate post_antes(table_state), to: Antes
  defdelegate post_blinds(table_state), to: Blinds
  defdelegate fold(table_state, seat), to: Fold
end
