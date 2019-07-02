defmodule Action do
  alias Action.{Bet, Call}
  defdelegate place_bet(table_state, seat, value), to: Bet
  defdelegate place_call(table_state, seat), to: Call
end
