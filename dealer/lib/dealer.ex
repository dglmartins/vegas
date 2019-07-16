defmodule Dealer do
  alias Dealer.StartHand
  defdelegate start_hand(table_state), to: StartHand
end
