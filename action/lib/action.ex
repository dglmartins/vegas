defmodule Action do
  alias Action.{Open, Call}
  defdelegate open_bet(table_state, seat, value), to: Open
  defdelegate place_call(table_state, seat), to: Call
end
