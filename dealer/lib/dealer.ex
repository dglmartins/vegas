defmodule Dealer do
  alias Dealer.StartHand
  defdelegate start_hand(table_state, hand_id), to: StartHand
end
