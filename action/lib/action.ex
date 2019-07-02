defmodule Action do
  alias Action.Bet
  defdelegate place_bet(table_state, seat, value), to: Bet
end
